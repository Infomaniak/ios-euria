/*
 Infomaniak Euria - iOS App
 Copyright (C) 2025 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import AVFoundation
import EuriaCore
import Foundation
import InfomaniakDI
import Sentry
import WebKit

// MARK: - WKScriptMessageHandler

extension EuriaWebViewDelegate: WKScriptMessageHandler {
    enum MessageTopic: String, CaseIterable {
        case logout
        case unauthenticated
        case shareImage
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let topic = MessageTopic(rawValue: message.name) else { return }

        switch topic {
        case .logout:
            logoutUser()
        case .unauthenticated:
            userTokenIsInvalid()
        default:
            break
        }
    }

    func uploadMediaToWebView(_ url: URL) {
        let mime = mimeType(for: url)
        if mime.hasPrefix("image") {
            uploadImageToWebView(url)
        } else if mime.hasPrefix("video") || mime.hasPrefix("audio") {
            sendVideoFileInChunks(url) {
                try? FileManager.default.removeItem(at: url)
            }
        }
    }

    private func logoutUser() {
        Task {
            let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
            await webConfiguration.websiteDataStore.removeData(
                ofTypes: dataTypes,
                modifiedSince: Date(timeIntervalSinceReferenceDate: 0)
            )

            @InjectService var accountManager: AccountManagerable
            guard let userId = await accountManager.currentSession?.userId else {
                return
            }

            await accountManager.removeTokenAndAccountFor(userId: userId)
        }
    }

    private func userTokenIsInvalid() {
        SentrySDK.capture(message: "Refreshing token failed - Cannot refresh infinite token") { scope in
            scope.setLevel(.error)
        }
        logoutUser()
    }

    private func mimeType(for url: URL) -> String {
        if let type = UTType(filenameExtension: url.pathExtension),
           let mime = type.preferredMIMEType {
            return mime
        }

        return "application/octet-stream"
    }

    private func uploadImageToWebView(_ url: URL) {
        guard let image = UIImage(contentsOfFile: url.path(percentEncoded: false)),
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        let imageFromBase64 = imageData.base64EncodedString()
        let script = "window.receiveImageFromApp('data:image/jpeg;base64,\(imageFromBase64)');"

        weakWebView?.evaluateJavaScript(script) { _, _ in
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func evaluateJS(_ script: String) async {
        await withCheckedContinuation { continuation in
            weakWebView?.evaluateJavaScript(script) { _, _ in
                continuation.resume()
            }
        }
    }

    private func sendVideoFileInChunks(_ url: URL,
                                       completion: (@Sendable () -> Void)? = nil) {
        let chunkSize = 256 * 1024
        let mime = mimeType(for: url)

        Task.detached {
            do {
                let file = try FileHandle(forReadingFrom: url)
                defer { try? file.close() }

                let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                let fileSize = (attributes?[.size] as? NSNumber)?.intValue ?? 0

                await self.evaluateJS("window.receiveVideoBegin('\(mime)', \(fileSize));")

                while true {
                    guard let data = try file.read(upToCount: chunkSize),
                          !data.isEmpty else { break }
                    let fileFromBase64 = data.base64EncodedString()

                    await self.evaluateJS("window.receiveVideoChunk('\(mime)', '\(fileFromBase64)', false);")
                }

                await self.evaluateJS("window.receiveVideoChunk('\(mime)', '', true);")
                await self.evaluateJS("window.receiveVideoDone();")
                await MainActor.run { completion?() }

            } catch {
                print("send error:", error)
                await MainActor.run { completion?() }
            }
        }
    }
}
