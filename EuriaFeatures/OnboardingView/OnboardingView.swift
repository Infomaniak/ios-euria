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

import AuthenticationServices
import EuriaCore
import EuriaCoreUI
import InfomaniakDI
import InfomaniakOnboarding
import InterAppLogin
import SwiftUI

public struct OnboardingView: View {
    @InjectService private var accountManager: AccountManagerable

    @EnvironmentObject private var rootViewState: RootViewState

    @State private var excludedUserIds: [AccountManagerable.UserId] = []
    @State private var loginHandler = LoginHandler()

    @State private var selectedSlideIndex = 0

    public init() {}

    public var body: some View {
        WaveView(slides: Slide.onboardingSlides, selectedSlide: $selectedSlideIndex) { slideIndex in
            if slideIndex == Slide.onboardingSlides.count - 1 {
                ContinueWithAccountView(isLoading: loginHandler.isLoading, excludingUserIds: excludedUserIds) {
                    Task {
                        do {
                            let session = try await loginHandler.login()
                            handleLoginSuccess(session: session)
                        } catch {
                            handleLoginError(error)
                        }
                    }
                } onLoginWithAccountsPressed: { accounts in
                    Task {
                        do {
                            let session = try await loginHandler.loginWith(accounts: accounts)
                            handleLoginSuccess(session: session)
                        } catch {
                            handleLoginError(error)
                        }
                    }
                } onCreateAccountPressed: {
                    // TODO: Handle Account creation
                }
                .disabled(loginHandler.isLoading)
                .task {
                    excludedUserIds = await accountManager.getAccountIds()
                }
            } else {
                Button {
                    selectedSlideIndex += 1
                } label: {
                    Text("Next Slide \(slideIndex + 1)")
                }
            }
        }
    }

    func handleLoginError(_ error: Error) {
        guard (error as? ASWebAuthenticationSessionError)?.code != .canceledLogin else { return }
        // TODO: Handle error
    }

    func handleLoginSuccess(session: any UserSessionable) {
        rootViewState.state = .mainView(MainViewState(userSession: session))
    }
}

#Preview {
    OnboardingView()
}

extension Slide {
    static var onboardingSlides: [Slide] {
        return [
            Slide(
                backgroundImage: UIImage(),
                backgroundImageTintColor: nil,
                content: .illustration(UIImage(systemName: "arrow.right") ?? UIImage()),
                bottomView: VStack(spacing: 8) {
                    Text("Slide1")
                }
            ),
            Slide(
                backgroundImage: UIImage(),
                backgroundImageTintColor: nil,
                content: .illustration(UIImage(systemName: "arrow.left.arrow.right") ?? UIImage()),
                bottomView: VStack(spacing: 8) {
                    Text("Slide2")
                }
            ),
            Slide(
                backgroundImage: UIImage(),
                backgroundImageTintColor: nil,
                content: .illustration(UIImage(systemName: "arrow.left") ?? UIImage()),
                bottomView: VStack(spacing: 8) {
                    Text("Slide3")
                }
            )
        ]
    }
}
