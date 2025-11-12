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

    func uploadImageToWebView(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            return
        }
        let imageFromBase64 = imageData.base64EncodedString()
        let script = "window.receiveImageFromApp('data:image/jpeg;base64,\(imageFromBase64)');"

        weakWebView?.evaluateJavaScript(script)
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
}
