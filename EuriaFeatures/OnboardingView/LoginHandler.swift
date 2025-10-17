/*
 Infomaniak Euria - iOS App
 Copyright (C) 2025 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import AuthenticationServices
import EuriaCore
import EuriaCoreUI
import InfomaniakConcurrency
import InfomaniakCore
import InfomaniakDeviceCheck
import InfomaniakDI
import InfomaniakLogin
import InfomaniakOnboarding
import InterAppLogin
import SwiftUI

@MainActor
final class LoginHandler: ObservableObject {
    @LazyInjectService private var loginService: InfomaniakLoginable
    @LazyInjectService private var tokenService: InfomaniakNetworkLoginable
    @LazyInjectService private var accountManager: AccountManagerable

    @Published var isLoading = false

    func login() async throws -> (any UserSessionable) {
        isLoading = true

        let result = try await loginService.asWebAuthenticationLoginFrom(
            anchor: ASPresentationAnchor(),
            useEphemeralSession: true,
            hideCreateAccountButton: true
        )

        let session = try await loginSuccessful(code: result.code, codeVerifier: result.verifier)

        return session
    }

    func loginWith(accounts: [ConnectedAccount]) async throws -> (any UserSessionable) {
        isLoading = true
        let sessions = await accounts.asyncCompactMap { account in
            do {
                let derivatedToken = try await self.tokenService.derivateApiToken(for: account)

                let session = try await self.accountManager.createAccount(token: derivatedToken)
                return session
            } catch {
                return nil
            }
        }

        guard let firstSession = sessions.first else {
            fatalError("No session could be created") // TODO: Handle error
        }

        isLoading = false
        return firstSession
    }

    private func loginSuccessful(code: String, codeVerifier verifier: String) async throws -> (any UserSessionable) {
        let session = try await accountManager.createAccount(code: code, codeVerifier: verifier)
        isLoading = false
        return session
    }
}
