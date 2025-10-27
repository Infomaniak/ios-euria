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
import EuriaCoreUI
import InfomaniakCore
import InfomaniakDI
import SwiftUI
import WebKit

public struct MainView: View {
    @LazyInjectService private var accountManager: AccountManagerable

    @EnvironmentObject private var rootViewState: RootViewState
    @EnvironmentObject private var mainViewState: MainViewState

    private let webConfiguration = WKWebViewConfiguration()
    private let euriaNavigationDelegate = EuriaNavigationHandler()

    public init() {}

    public var body: some View {
        NavigationStack {
            WebView(
                url: URL(string: "https://\(ApiEnvironment.current.euriaHost)/")!,
                webConfiguration: webConfiguration,
                navigationDelegate: euriaNavigationDelegate
            )
            .task {
                await setEuriaConfiguration(webConfiguration: webConfiguration)
            }
        }
    }

    func setEuriaConfiguration(webConfiguration: WKWebViewConfiguration) async {
        let cookieStore = webConfiguration.websiteDataStore.httpCookieStore

        if let token = mainViewState.userSession.apiFetcher.currentToken,
           let tokenCookie = HTTPCookie(properties: [
               .name: "USER-TOKEN", .value: "\(token.accessToken)", .path: "/",
               .domain: ApiEnvironment.current.euriaHost
           ]) {
            await setCookie(cookie: tokenCookie, store: cookieStore)
        }

        if let languageCookie = HTTPCookie(properties: [
            .name: "USER-LANGUAGE", .value: Locale.current.language.languageCode?.identifier ?? "en", .path: "/",
            .domain: ApiEnvironment.current.euriaHost
        ]) {
            await setCookie(cookie: languageCookie, store: cookieStore)
        }

        webConfiguration.userContentController.add(euriaNavigationDelegate, name: "logout")
    }

    func setCookie(cookie: HTTPCookie, store: WKHTTPCookieStore) async {
        await withCheckedContinuation { cont in
            store.setCookie(cookie) { cont.resume() }
        }
    }
}

protocol WebViewControllable: WKScriptMessageHandler, WKNavigationDelegate {}

#Preview {
    MainView()
}
