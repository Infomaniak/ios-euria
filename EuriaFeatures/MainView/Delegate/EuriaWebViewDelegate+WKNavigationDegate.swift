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
import InfomaniakCore
import WebKit

// MARK: - WKNavigationDelegate

extension EuriaWebViewDelegate: WKNavigationDelegate {
    private var authorizedHosts: Set<String> {
        return [host, ApiEnvironment.current.driveHost, ApiEnvironment.current.kDriveHost]
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard !navigationAction.shouldPerformDownload else {
            return .download
        }

        guard let navigationHost = navigationAction.request.url?.host() else {
            return .allow
        }

        if authorizedHosts.contains(navigationHost) {
            return .allow
        }

        if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
            await UIApplication.shared.open(url)
        }
        return .cancel
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoaded = true
    }

    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        reloadWebView()
    }
}
