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
import InfomaniakLogin
import Sentry
import SwiftUI
import UIKit
import WebKit

@MainActor
class EuriaWebViewDelegate: NSObject, ObservableObject {
    @Published var isLoaded = false

    let webConfiguration: WKWebViewConfiguration

    enum Cookie: String {
        case userToken = "USER-TOKEN"
        case userLanguage = "USER-LANGUAGE"
    }

    init(session: any UserSessionable) {
        webConfiguration = WKWebViewConfiguration()
        super.init()
        setupWebViewConfiguration(token: session.apiFetcher.currentToken)
    }

    private func setupWebViewConfiguration(token: ApiToken?) {
        addCookies(token: token)
        addUserContentControllers()
    }

    private func addCookies(token: ApiToken?) {
        let cookieStore = webConfiguration.websiteDataStore.httpCookieStore

        if let token, let tokenCookie = createCookie(cookie: .userToken, value: "\(token.accessToken)") {
            cookieStore.setCookie(tokenCookie)
        }

        let language = Locale.current.language.languageCode?.identifier ?? "en"
        if let languageCookie = createCookie(cookie: .userLanguage, value: language) {
            cookieStore.setCookie(languageCookie)
        }
    }

    private func addUserContentControllers() {
        for topic in EuriaWebViewDelegate.MessageTopic.allCases {
            webConfiguration.userContentController.add(self, name: topic.rawValue)
        }
    }

    private func createCookie(cookie: EuriaWebViewDelegate.Cookie, value: String) -> HTTPCookie? {
        return HTTPCookie(
            properties: [
                .name: cookie.rawValue,
                .value: value,
                .path: "/",
                .domain: ApiEnvironment.current.euriaHost,
                .maximumAge: TimeInterval.sixMonths
            ]
        )
    }
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
        isLoaded = true
    }
}

// MARK: - WKScriptMessageHandler

extension EuriaWebViewDelegate: WKScriptMessageHandler {
    enum MessageTopic: String, CaseIterable {
        case logout
        case unauthenticated
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let topic = MessageTopic(rawValue: message.name) else { return }

        switch topic {
        case .logout:
            logoutUser()
        case .unauthenticated:
            userTokenIsInvalid()
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
}
