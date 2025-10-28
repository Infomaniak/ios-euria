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
import InfomaniakCore
import InfomaniakDI
import SwiftUI
import UIKit
import WebKit

@MainActor
class EuriaWebViewDelegate: NSObject, ObservableObject {
    let webConfiguration = WKWebViewConfiguration()
    @Published var didLoad = false
}

// MARK: - WKNavigationDelegate

extension EuriaWebViewDelegate: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @MainActor (WKNavigationActionPolicy) -> Void
    ) {
        guard let navigationHost = navigationAction.request.url?.host() else {
            decisionHandler(.allow)
            return
        }

        if navigationHost == ApiEnvironment.current.euriaHost {
            decisionHandler(.allow)
        } else {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url {
                UIApplication.shared.open(url)
            }
            decisionHandler(.cancel)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didLoad = true
    }
}

// MARK: - WKScriptMessageHandler

extension EuriaWebViewDelegate: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.body as? String == "logout" {
            logoutUser()
        }
    }

    private func logoutUser() {
        Task {
            @InjectService var accountManager: AccountManagerable
            guard let userId = await accountManager.currentSession?.userId else {
                return
            }
            print("logOut")
            await accountManager.removeTokenAndAccountFor(userId: userId)
        }
    }
}
