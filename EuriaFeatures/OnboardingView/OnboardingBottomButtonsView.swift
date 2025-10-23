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
import DesignSystem
import EuriaCore
import EuriaResources
import InfomaniakCoreUIResources
import InfomaniakCreateAccount
import InfomaniakDI
import InfomaniakOnboarding
import InterAppLogin
import SwiftUI

struct OnboardingBottomButtonsView: View {
    @ObservedObject var loginHandler = LoginHandler()

    @State private var excludedUserIds: [AccountManagerable.UserId] = []

    @Binding var selection: Int

    let slideCount: Int

    private var isLastSlide: Bool {
        return selection == slideCount - 1
    }

    var body: some View {
        VStack(spacing: IKPadding.mini) {
            ContinueWithAccountView(isLoading: loginHandler.isLoading, excludingUserIds: excludedUserIds) {
                loginPressed()
            } onLoginWithAccountsPressed: { accounts in
                loginWithAccountsPressed(accounts: accounts)
            } onCreateAccountPressed: {
                isPresentingCreateAccount = true
            }
        }
        .ikButtonFullWidth(true)
        .controlSize(.large)
        .opacity(isLastSlide ? 1 : 0)
        .overlay {
            if !isLastSlide {
                Button {
                    withAnimation {
                        selection = min(slideCount - 1, selection + 1)
                    }
                } label: {
                    Label {
                        Text(CoreUILocalizable.buttonNext)
                    } icon: {
                        EuriaResourcesAsset.Images.arrowRight.swiftUIImage
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.ikSquare)
                .controlSize(.large)
            }
        }
        .padding(.horizontal, value: .large)
        .padding(.bottom, IKPadding.medium)
        .sheet(isPresented: $isPresentingCreateAccount) {
            RegisterView(registrationProcess: .mail) { viewController in
                guard let viewController else { return }
                loginHandler.loginAfterAccountCreation(from: viewController)
            }
        }
        .task {
            @InjectService var accountManager: AccountManagerable
            excludedUserIds = await accountManager.getAccountIds()
        }
    }

    private func loginPressed() {
        Task {
            await loginHandler.login()
        }
    }

    private func loginWithAccountsPressed(accounts: [ConnectedAccount]) {
        Task {
            await loginHandler.loginWith(accounts: accounts)
        }
    }
}
