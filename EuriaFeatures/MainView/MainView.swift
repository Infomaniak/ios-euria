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
import InAppTwoFactorAuthentication
import InfomaniakConcurrency
import InfomaniakCore
import InfomaniakDI
import SwiftUI
import WebKit

public struct MainView: View {
    @InjectService private var accountManager: AccountManagerable

    @EnvironmentObject private var mainViewState: MainViewState

    @StateObject private var webViewDelegate = EuriaWebViewDelegate()
    @State private var isShowingWebView = true

    @ObservedObject var networkMonitor = NetworkMonitor.shared

    private var isShowingOfflineView: Bool {
        return !networkMonitor.isConnected && !webViewDelegate.isLoaded
    }

    public init() {}

    public var body: some View {
        ZStack {
            if isShowingWebView {
                WebView(
                    url: URL(string: "https://\(ApiEnvironment.current.euriaHost)/")!,
                    webConfiguration: webViewDelegate.webConfiguration,
                    delegate: webViewDelegate
                )
            }

            if isShowingOfflineView {
                OfflineView()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            networkMonitor.start()
            setupWebViewConfiguration()
        }
        .onChange(of: networkMonitor.isConnected) { isConnected in
            guard !webViewDelegate.isLoaded else { return }
            isShowingWebView = isConnected
        }
        .sceneLifecycle(willEnterForeground: willEnterForeground)
    }

    private func willEnterForeground() {
        Task {
            await checkTwoFAChallenges()
        }
    }

    private func checkTwoFAChallenges() async {
        let sessions: [InAppTwoFactorAuthenticationSession] = await accountManager.accounts.asyncCompactMap { account in
            guard let user = await accountManager.userProfileStore.getUserProfile(id: account.userId) else {
                return nil
            }

            let apiFetcher = await accountManager.getApiFetcher(for: account.userId, token: account)

            let session = InAppTwoFactorAuthenticationSession(user: user, apiFetcher: apiFetcher)
            return session
        }

        @InjectService var inAppTwoFactorAuthenticationManager: InAppTwoFactorAuthenticationManagerable
        inAppTwoFactorAuthenticationManager.checkConnectionAttempts(using: sessions)
    }

    private func setupWebViewConfiguration() {
        addCookies()
        addUserContentControllers()
    }

    private func addCookies() {
        let cookieStore = webViewDelegate.webConfiguration.websiteDataStore.httpCookieStore

        if let token = mainViewState.userSession.apiFetcher.currentToken,
           let tokenCookie = createCookie(name: "USER-TOKEN", value: "\(token.accessToken)") {
            cookieStore.setCookie(tokenCookie)
        }

        if let languageCookie = createCookie(
            name: "USER-LANGUAGE",
            value: Locale.current.language.languageCode?.identifier ?? "en"
        ) {
            cookieStore.setCookie(languageCookie)
        }
    }

    private func addUserContentControllers() {
        webViewDelegate.webConfiguration.userContentController.add(webViewDelegate, name: "logout")
    }

    private func createCookie(name: String, value: String) -> HTTPCookie? {
        return HTTPCookie(properties: [.name: name, .value: value, .path: "/", .domain: ApiEnvironment.current.euriaHost])
    }
}

#Preview {
    MainView()
}
