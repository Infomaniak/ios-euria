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

import InfomaniakLogin
import SwiftUI
import WebKit

struct UpgradeAccountView: UIViewRepresentable {
    let accessToken: ApiToken

    class Coordinator: NSObject, WKNavigationDelegate {
        let initialRequest: URLRequest?

        init(initialRequest: URLRequest?) {
            self.initialRequest = initialRequest
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @MainActor (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            guard url.scheme == "https",
                  url.host == "manager.infomaniak.com" ||
                  url.host == "welcome.infomaniak.com" else {
                decisionHandler(.cancel)
                return
            }

            if navigationAction.targetFrame == nil {
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }
    }

    func makeCoordinator() -> Coordinator {
        let initialRequest: URLRequest?
        if let url = Constants.autologinUrl(to: "https://welcome.infomaniak.com/signup/euria") {
            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken.accessToken)", forHTTPHeaderField: "Authorization")
            initialRequest = request
        } else {
            initialRequest = nil
        }
        return Coordinator(initialRequest: initialRequest)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator

        if let request = context.coordinator.initialRequest {
            webView.load(request)
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
