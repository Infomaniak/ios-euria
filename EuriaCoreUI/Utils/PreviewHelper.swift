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

import EuriaCore
import Foundation
import InfomaniakCore
import InfomaniakLogin

extension PreviewHelper {
    private class PreviewHelperRefreshTokenDelegate: RefreshTokenDelegate {
        func didUpdateToken(newToken: ApiToken, oldToken: ApiToken) {}

        func didFailRefreshToken(_ token: ApiToken) {}
    }
}

public enum PreviewHelper {
    public static let userSession: any UserSessionable = {
        let apiToken = ApiToken(
            accessToken: "",
            expiresIn: 0,
            refreshToken: "",
            scope: "",
            tokenType: "",
            userId: 0,
            expirationDate: Date(timeIntervalSinceNow: 1_000_000)
        )
        let apiFetcher = ApiFetcher(token: apiToken, delegate: PreviewHelperRefreshTokenDelegate())

        let session = UserSession(userId: 42, apiFetcher: apiFetcher)
        return session
    }()
}
