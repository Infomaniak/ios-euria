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

import EuriaCoreUI
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @EnvironmentObject private var mainViewState: MainViewState
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        if let token = mainViewState.userSession.apiFetcher.currentToken,
           let tokenCookie = HTTPCookie(
            properties: [.name: "USER-TOKEN", .value: "\(token.accessToken)", .path: "/", .domain: "local.euria.dev.infomaniak.ch"]
           ) {
            print(token)
            configuration.websiteDataStore.httpCookieStore.setCookie(tokenCookie)
        }

        let webView = WKWebView(frame: .zero, configuration: configuration)
        let request = URLRequest(url: url)
        webView.load(request)

        webView.navigationDelegate = context.coordinator

        webView.isInspectable = true

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update the view.
    }

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        return coordinator
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping @MainActor (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            let protectionSpace = challenge.protectionSpace
            if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
               let serverTrust = protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        }
    }
}
