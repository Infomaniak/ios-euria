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
import WebKit

// MARK: - WKNavigationDelegate

extension EuriaWebViewDelegate: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if let url = navigationAction.request.url,
           url.host() == host,
           url.path.hasSuffix("/download") {
            await downloadFile(from: url)
            return .cancel
        }

        guard !navigationAction.shouldPerformDownload else {
            return .download
        }

        guard let navigationHost = navigationAction.request.url?.host() else {
            return .allow
        }

        if navigationHost == host {
            return .allow
        }

        if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
            await UIApplication.shared.open(url)
        }
        return .cancel
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoaded = true
        enableAppFeatures()
    }

    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        reloadWebView()
    }

    private func enableAppFeatures() {
        let featuresTab = AppFeatures.allCases.map { "'\($0.rawValue)'" }.joined(separator: ",")
        let scriptSource = "enableAppFeatures([\(featuresTab)]);"

        webView?.evaluateJavaScript(scriptSource)
    }

    private func downloadFile(from url: URL) async {
        guard let token = currentToken else {
            error = .downloadFailed(error: NSError(domain: "Euria", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Missing authentication token"
            ]))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let (temporaryLocalURL, response) = try await URLSession.shared.download(for: request)
            guard let response = response as? HTTPURLResponse, (200 ... 299).contains(response.statusCode) else {
                error = .downloadFailed(error: NSError(domain: "Euria", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Server returned an error"
                ]))
                return
            }

            let path = response.suggestedFilename ?? url.lastPathComponent

            let destinationURL = try URL.temporaryDownloadsDirectory().appending(path: path)
            if FileManager.default.fileExists(atPath: destinationURL.path(percentEncoded: false)) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.moveItem(at: temporaryLocalURL, to: destinationURL)

            isPresentingDocument = destinationURL
        } catch {
            self.error = .downloadFailed(error: error)
        }
    }
}
