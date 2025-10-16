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

import Foundation
import InfomaniakCore
import InfomaniakDI
import InfomaniakLogin

public protocol AccountManagerable: Sendable {
    typealias UserId = Int

    func createAccount(token: ApiToken) async throws
    func getUserSession(for userId: UserId) async -> (any UserSessionable)?
    func getFirstSession() async -> (any UserSessionable)?
}

public actor AccountManager: AccountManagerable {
    @LazyInjectService var tokenStore: TokenStore

    private var sessions: [AccountManagerable.UserId: UserSession] = [:]

    public init() {}

    public func createAccount(token: ApiToken) async throws {}

    public func updateAccount(token: ApiToken) async throws {}

    public func getUserSession(for userId: AccountManagerable.UserId) async -> (any UserSessionable)? {
        if let session = sessions[userId] {
            return session
        } else if let token = tokenStore.tokenFor(userId: userId) {
            sessions[userId] = UserSession(token: token)
            return sessions[userId]
        } else {
            return nil
        }
    }

    public func getFirstSession() async -> (any UserSessionable)? {
        guard let firstToken = tokenStore.getAllTokens().values.first else {
            return nil
        }

        sessions[firstToken.userId] = UserSession(token: firstToken)
        return sessions[firstToken.userId]
    }
}
