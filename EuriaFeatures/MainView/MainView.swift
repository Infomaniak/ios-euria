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

import AVFoundation
import EuriaCore
import EuriaCoreUI
import InAppTwoFactorAuthentication
import InfomaniakConcurrency
import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakCoreUIResources
import InfomaniakDI
import InfomaniakLogin
import SwiftUI
import WebKit

public struct MainView: View {
    @EnvironmentObject private var universalLinksState: UniversalLinksState

    @StateObject private var webViewDelegate: EuriaWebViewDelegate

    @State private var navigationDestination: NavigationDestination?
    @State private var isShowingWebView = true
    @State private var isShowingErrorAlert = false

    @ObservedObject var networkMonitor = NetworkMonitor.shared

    private var isShowingOfflineView: Bool {
        return !networkMonitor.isConnected && !webViewDelegate.isLoaded
    }

    private var isShowingLoadingView: Bool {
        return !webViewDelegate.isLoaded && !isShowingOfflineView
    }

    public init(session: any UserSessionable) {
        _webViewDelegate = StateObject(wrappedValue: EuriaWebViewDelegate(
            host: ApiEnvironment.current.euriaHost,
            session: session
        ))
    }

    public var body: some View {
        ZStack {
            if isShowingWebView {
                WebView(
                    url: URL(string: "https://\(ApiEnvironment.current.euriaHost)/")!,
                    navigationDestination: navigationDestination,
                    webConfiguration: webViewDelegate.webConfiguration,
                    webViewCoordinator: webViewDelegate
                )
                .ignoresSafeArea()
                .quickLookPreview($webViewDelegate.isPresentingDocument)
                .onChange(of: webViewDelegate.error) { newValue in
                    guard newValue != nil else { return }
                    isShowingErrorAlert = true
                }
                .alert(isPresented: $isShowingErrorAlert, error: webViewDelegate.error) {
                    Button(InfomaniakCoreUIResources.CoreUILocalizable.buttonClose) {
                        webViewDelegate.error = nil
                    }
                }
            }

            if isShowingOfflineView {
                OfflineView()
            } else if isShowingLoadingView {
                SplashScreenView()
            }
        }
        .appBackground()
        .onAppear {
            networkMonitor.start()
            @InjectService var orientationManager: OrientationManageable
            orientationManager.setOrientationLock(.all)
        }
        .onChange(of: networkMonitor.isConnected) { isConnected in
            guard !webViewDelegate.isLoaded else { return }
            isShowingWebView = isConnected
        }
        .onChange(of: universalLinksState.linkedWebView) { identifiableURL in
            guard let identifiableURL else { return }

            navigationDestination = NavigationDestination(url: identifiableURL.url)
            universalLinksState.linkedWebView = nil
        }
        .sceneLifecycle(willEnterForeground: willEnterForeground)
    }

    private func willEnterForeground() {
        Task {
            await checkTwoFAChallenges()
        }
    }

    private func checkTwoFAChallenges() async {
        @InjectService var accountManager: AccountManagerable
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
}

#Preview {
    MainView(session: PreviewHelper.userSession)
        .environmentObject(MainViewState(userSession: PreviewHelper.userSession))
}
