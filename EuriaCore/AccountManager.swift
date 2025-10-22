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

import Combine
import DeviceAssociation
import Foundation
import InfomaniakCore
import InfomaniakDI
import InfomaniakLogin
import OSLog

public protocol AccountManagerable: Sendable {
    typealias UserId = Int

    var currentSession: (any UserSessionable)? { get async }

    var objectWillChange: ObservableObjectPublisher { get }

    func createAndSetCurrentAccount(code: String, codeVerifier: String) async throws
    func createAccount(token: ApiToken) async throws -> (any UserSessionable)
    func updateAccount(token: ApiToken) async throws
    func removeTokenAndAccountFor(userId: Int) async
    func setCurrentSession(session: any UserSessionable) async
    func getUserSession(for userId: UserId) async -> (any UserSessionable)?
    func getFirstSession() async -> (any UserSessionable)?
    func getAccountIds() async -> [AccountManagerable.UserId]
}

public actor AccountManager: AccountManagerable, ObservableObject {
    @LazyInjectService var deviceManager: DeviceManagerable
    @LazyInjectService var tokenStore: TokenStore
    @LazyInjectService var networkLoginService: InfomaniakNetworkLoginable

    public let userProfileStore = UserProfileStore()

    private let refreshTokenDelegate = RefreshTokenDelegate()

    public private(set) var currentSession: (any UserSessionable)? {
        didSet {
            objectWillChange.send()
        }
    }

    private var sessions: [UserId: UserSession] = [:]
    private var apiFetchers: [UserId: ApiFetcher] = [:]

    public init() {}

    public func createAndSetCurrentAccount(code: String, codeVerifier: String) async throws {
        let token = try await networkLoginService.apiTokenUsing(code: code, codeVerifier: codeVerifier)

        do {
            let session = try await createAccount(token: token)
            await setCurrentSession(session: session)
        } catch {
            throw error
        }
    }

    public func createAccount(token: ApiToken) async throws -> (any UserSessionable) {
        let temporaryApiFetcher = ApiFetcher(token: token, delegate: refreshTokenDelegate)
        let user = try await userProfileStore.updateUserProfile(with: temporaryApiFetcher)

        let deviceId = try await deviceManager.getOrCreateCurrentDevice().uid
        tokenStore.addToken(newToken: token, associatedDeviceId: deviceId)

        guard let session = await getUserSession(for: user.id) as? UserSession else {
            // TODO: throw real error
            fatalError("Failed to retrieve user session after creating account")
        }

        attachDeviceToApiToken(token, apiFetcher: session.apiFetcher)

        return session
    }

    public func setCurrentSession(session: any UserSessionable) async {
        currentSession = session
    }

    public func updateAccount(token: ApiToken) async throws {
        // TODO: Implement account update logic if needed based on Mail
    }

    public func removeTokenAndAccountFor(userId: Int) {
        let removedToken = tokenStore.removeTokenFor(userId: userId)
        sessions.removeValue(forKey: userId)
        apiFetchers.removeAll()
        deviceManager.forgetLocalDeviceHash(forUserId: userId)

        guard let removedToken else { return }

        networkLoginService.deleteApiToken(token: removedToken) { result in
            guard case .failure(let error) = result else { return }
            Logger.general.error("Failed to delete api token: \(error.localizedDescription)")
        }
    }

    private func attachDeviceToApiToken(_ token: ApiToken, apiFetcher: ApiFetcher) {
        Task {
            do {
                let device = try await deviceManager.getOrCreateCurrentDevice()
                try await deviceManager.attachDeviceIfNeeded(device, to: token, apiFetcher: apiFetcher)
            } catch {
                Logger.general.error("Failed to attach device to token: \(error.localizedDescription)")
            }
        }
    }

    public func getUserSession(for userId: AccountManagerable.UserId) async -> (any UserSessionable)? {
        if let session = sessions[userId] {
            return session
        } else if let token = tokenStore.tokenFor(userId: userId) {
            let apiFetcher = getApiFetcher(for: userId, token: token.apiToken)
            sessions[userId] = UserSession(userId: userId, apiFetcher: apiFetcher)
            return sessions[userId]
        } else {
            return nil
        }
    }

    public func getApiFetcher(for userId: Int, token: ApiToken) -> ApiFetcher {
        if let apiFetcher = apiFetchers[userId] {
            return apiFetcher
        } else {
            let apiFetcher = ApiFetcher(token: token, delegate: refreshTokenDelegate)
            apiFetchers[userId] = apiFetcher
            return apiFetcher
        }
    }

    public func getFirstSession() async -> (any UserSessionable)? {
        guard let firstToken = tokenStore.getAllTokens().values.first,
              let session = await getUserSession(for: firstToken.userId) else {
            return nil
        }

        return session
    }

    public func getAccountIds() async -> [AccountManagerable.UserId] {
        return Array(sessions.keys)
    }
}
