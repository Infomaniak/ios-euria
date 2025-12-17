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

import InfomaniakCore
import InfomaniakCreateAccount
import InfomaniakLogin
import SwiftUI
import WebKit

struct UpgradeAccountView: UIViewRepresentable {
    @Environment(\.dismiss) private var dismiss

    let accessToken: ApiToken
    let onUpgradeCompleted: (() -> Void)?

    static let welcomeRoute = URL(string: "https://welcome.infomaniak.com/signup/euria")!
    static let managerRoute = Constants.autologinUrl(to: welcomeRoute.absoluteString)!

    class Coordinator: NSObject, WKNavigationDelegate {
        let dismissAction: () -> Void
        let onUpgradeCompleted: (() -> Void)?

        init(dismissAction: @escaping () -> Void, onUpgradeCompleted: (() -> Void)?) {
            self.dismissAction = dismissAction
            self.onUpgradeCompleted = onUpgradeCompleted
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

            if url.host == ApiEnvironment.current.euriaHost {
                decisionHandler(.cancel)
                onUpgradeCompleted?()
                dismissAction()
            } else {
                guard url.host == managerRoute.host() ||
                    url.host == welcomeRoute.host() else {
                    decisionHandler(.cancel)
                    return
                }
                decisionHandler(.allow)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            dismissAction: { dismiss() },
            onUpgradeCompleted: onUpgradeCompleted
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator

        var request = URLRequest(url: UpgradeAccountView.managerRoute)
        request.setValue("Bearer \(accessToken.accessToken)", forHTTPHeaderField: "Authorization")
        webView.load(request)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
