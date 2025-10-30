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
@preconcurrency import InfomaniakCore
import InfomaniakLogin

public final class EuriaRefreshTokenDelegate: InfomaniakCore.RefreshTokenDelegate, Sendable {
    public func didUpdateToken(newToken: ApiToken, oldToken: ApiToken) {}

    public func didFailRefreshToken(_ token: ApiToken) {}
}

public protocol UserSessionable: Sendable {
    var userId: Int { get }
    var apiFetcher: ApiFetcher { get }
}

public extension ApiFetcher {
    convenience init(token: ApiToken, delegate: RefreshTokenDelegate) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.init(decoder: decoder)
        createAuthenticatedSession(
            token,
            authenticator: OAuthAuthenticator(refreshTokenDelegate: delegate),
            additionalAdapters: [UserAgentAdapter()]
        )
    }
}

public struct UserSession: UserSessionable {
    public let apiFetcher: ApiFetcher
    public let userId: Int

    public init(userId: Int, apiFetcher: ApiFetcher) {
        self.userId = userId
        self.apiFetcher = apiFetcher
    }
}
