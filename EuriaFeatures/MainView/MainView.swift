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
import EuriaOnboardingView
import InAppTwoFactorAuthentication
import InfomaniakConcurrency
import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakCoreUIResources
import InfomaniakCreateAccount
import InfomaniakDI
import InfomaniakLogin
import InfomaniakNotifications
import SwiftUI
import WebKit

public struct MainView: View {
    @InjectService var orientationManager: OrientationManageable
    @EnvironmentObject private var universalLinksState: UniversalLinksState

    @StateObject private var webViewDelegate: EuriaWebViewDelegate

    @State private var isShowingWebView = true
    @State private var isShowingErrorAlert = false

    @ObservedObject var networkMonitor = NetworkMonitor.shared
    @ObservedObject var loginHandler = LoginHandler()

    private let session: (any UserSessionable)?

    private var isShowingOfflineView: Bool {
        return !networkMonitor.isConnected && !webViewDelegate.isLoaded
    }

    private var isShowingLoadingView: Bool {
        return !webViewDelegate.isLoaded && !isShowingOfflineView
    }

    public init(session: (any UserSessionable)?) {
        self.session = session
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
            orientationManager.setOrientationLock(.all)
        }
        .onChange(of: networkMonitor.isConnected) { isConnected in
            guard !webViewDelegate.isLoaded else { return }
            isShowingWebView = isConnected
        }
        .onChange(of: universalLinksState.linkedWebView) { navigationDestination in
            guard let navigationDestination else { return }

            webViewDelegate.enqueueNavigation(destination: navigationDestination.string)
            universalLinksState.linkedWebView = nil
        }
        .fullScreenCover(isPresented: $webViewDelegate.isShowingLoginView, onDismiss: {
            webViewDelegate.isShowingLoginView = false
            orientationManager.setOrientationLock(.all)
            UIApplication.shared.mainSceneKeyWindow?.rootViewController?
                .setNeedsUpdateOfSupportedInterfaceOrientations()
        }, content: {
            SingleOnboardingView()
        })
        .sheet(isPresented: $webViewDelegate.isShowingRegisterView) {
            RegisterView(registrationProcess: .mail) { viewController in
                guard let viewController else { return }
                loginHandler.loginAfterAccountCreation(from: viewController)
            }
        }
        .sceneLifecycle(willEnterForeground: willEnterForeground, didEnterBackground: didEnterBackground)
    }

    private func willEnterForeground() {
        Task {
            async let _ = registerForNotificationIfNeeded()
            await checkTwoFAChallenges()
        }
    }

    private func didEnterBackground() {
        UIApplication.shared.isIdleTimerDisabled = false
    }

    private func registerForNotificationIfNeeded() async {
        let options: UNAuthorizationOptions = [.alert, .sound]
        guard let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: options),
              granted else {
            return
        }
        guard let apiFetcher = session?.apiFetcher else {
            return
        }
        @InjectService var notificationService: InfomaniakNotifications
        await notificationService.updateTopicsIfNeeded([Topic.twoFAPushChallenge], userApiFetcher: apiFetcher)
    }

    private func checkTwoFAChallenges() async {
        @InjectService var accountManager: AccountManagerable
        let sessions: [InAppTwoFactorAuthenticationSession] = await accountManager.accounts.asyncCompactMap { account in
            guard let user = await accountManager.userProfileStore.getUserProfile(id: account.userId) else {
                return nil
            }

            let apiFetcher = await accountManager.getApiFetcher(for: account.userId, token: account)

            return InAppTwoFactorAuthenticationSession(user: user, apiFetcher: apiFetcher)
        }

        @InjectService var inAppTwoFactorAuthenticationManager: InAppTwoFactorAuthenticationManagerable
        inAppTwoFactorAuthenticationManager.checkConnectionAttempts(using: sessions)
    }
}

#Preview {
    MainView(session: PreviewHelper.userSession)
        .environmentObject(MainViewState(userSession: PreviewHelper.userSession))
}
