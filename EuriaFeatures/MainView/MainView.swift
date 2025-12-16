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
import InfomaniakCoreSwiftUI
import InfomaniakCoreUIResources
import InfomaniakCreateAccount
import InfomaniakDI
import InfomaniakLogin
import InfomaniakNotifications
import SwiftUI
import UIKit
import WebKit

public struct MainView: View {
    @InjectService var orientationManager: OrientationManageable
    @InjectService var accountManager: AccountManagerable

    @EnvironmentObject private var universalLinksState: UniversalLinksState
    @EnvironmentObject private var uploadManager: UploadManager

    @StateObject private var webViewDelegate: EuriaWebViewDelegate

    @State private var isShowingWebView = true
    @State private var isShowingErrorAlert = false

    @State private var isShowingCamera = false
    @State private var selectedCameraImage: UIImage?

    @ObservedObject var networkMonitor = NetworkMonitor.shared
    @ObservedObject var loginHandler = LoginHandler()

    private let session: any UserSessionable

    private var isShowingOfflineView: Bool {
        return !networkMonitor.isConnected && !webViewDelegate.isLoaded
    }

    private var isShowingLoadingView: Bool {
        return !webViewDelegate.isLoaded && !isShowingOfflineView
    }

    public init(session: any UserSessionable) {
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
                .alert(
                    Text(CoreUILocalizable.reviewAlertTitle(Constants.appName)),
                    isPresented: $webViewDelegate.isShowingReviewAlert
                ) {
                    Button(CoreUILocalizable.buttonYes) {
                        @InjectService var reviewManager: ReviewManageable
                        reviewManager.requestReview()
                    }
                    Button(CoreUILocalizable.buttonNo, role: .cancel) {}
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
            uploadManager.bridge = webViewDelegate
            if let navigationDestination = universalLinksState.linkedWebView {
                navigateTo(navigationDestination.string)
            }
        }
        .onChange(of: networkMonitor.isConnected) { isConnected in
            guard !webViewDelegate.isLoaded else { return }
            isShowingWebView = isConnected
        }
        .onChange(of: universalLinksState.linkedWebView) { navigationDestination in
            guard let navigationDestination else { return }
            navigateTo(navigationDestination.string)
        }
        .sheet(isPresented: $webViewDelegate.isShowingRegisterView) {
            RegisterView(registrationProcess: .euria) { viewController in
                guard let viewController else { return }
                loginHandler.loginAfterAccountCreation(from: viewController)
            }
        }
        .sheet(isPresented: $webViewDelegate.isShowingUpgradeView) {
            if let accessToken = session.apiFetcher.currentToken {
                UpgradeAccountView(accessToken: accessToken)
            }
        }
        .onReceive(accountManager.objectWillChange) { _ in
            Task {
                guard let session = await accountManager.currentSession else {
                    return
                }
                webViewDelegate.updateSessionToken(session)
            }
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPickerView(selectedImage: $selectedCameraImage)
                .ignoresSafeArea()
        }
        .onChange(of: selectedCameraImage) { image in
            isShowingCamera = false
            if let image {
                webViewDelegate.uploadCameraImage(image: image, session: session, uploadManager: uploadManager)
            }
            selectedCameraImage = nil
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

        @InjectService var notificationService: InfomaniakNotifications
        await notificationService.updateTopicsIfNeeded([Topic.twoFAPushChallenge], userApiFetcher: session.apiFetcher)
    }

    private func checkTwoFAChallenges() async {
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

    private func navigateTo(_ destination: String) {
        if destination == NavigationConstants.cameraRoute {
            isShowingCamera = true
            universalLinksState.linkedWebView = nil
            return
        }

        webViewDelegate.enqueueNavigation(destination: destination)
        universalLinksState.linkedWebView = nil
    }
}

#Preview {
    MainView(session: PreviewHelper.userSession)
        .environmentObject(MainViewState(userSession: PreviewHelper.userSession))
}
