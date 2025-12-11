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

@MainActor
public class UploadManager: ObservableObject {
    enum DomainError: Error {
        case containerUnavailable
        case noValidFiles
        case invalidOrganizationId
        case bridgeCommunicationFailed
    }

    public weak var bridge: WebViewBridge?

    public init() {}

    public func handleImportSession(uuid: String, userSession: any UserSessionable) {
        guard !userSession.isGuest else { return }

        Task {
            try await handleImportSession(uuid: uuid, userSession: userSession)
        }
    }

    func handleImportSession(uuid: ImportHelper.ImportSessionUUID, userSession: any UserSessionable) async throws {
        guard let containerURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) else {
            throw DomainError.containerUnavailable
        }

        let importHelper = ImportHelper(baseURL: containerURL, importUUID: uuid)
        let validImportedFiles = try await prepareUploadSessionWith(importHelper: importHelper)

        let organizationId = try await getOrganizationId()

        let uploadApiFetcher = UploadApiFetcher(apiFetcher: userSession.apiFetcher, organizationId: organizationId)

        for importedFile in validImportedFiles {
            do {
                let result = try await uploadApiFetcher.uploadFile(importedFile: importedFile)
                await bridge?.callFunction(FileUploadDone(
                    ref: importedFile.ref,
                    remoteId: result.id,
                    name: result.name,
                    mimeType: result.mimeType
                ))
            } catch UploadApiFetcher.DomainError.apiError(let rawJson) {
                await bridge?.callFunction(FileUploadError(ref: importedFile.ref, error: rawJson))
            } catch {
                await bridge?.callFunction(FileUploadError(ref: importedFile.ref, error: ""))
            }
        }
    }

    func prepareUploadSessionWith(importHelper: ImportHelper) async throws -> [ImportedFile] {
        let importedFileURLs = importHelper.importedFileURLs
        let importedFiles: [ImportedFile] = importedFileURLs.map { ImportedFile(fileURL: $0) }

        guard let validFileUUIDs = await bridge?.callFunction(PrepareFilesForUpload(files: importedFiles)) else {
            throw DomainError.bridgeCommunicationFailed
        }

        let validFiles = importedFiles.filter { validFileUUIDs.contains($0.ref) }

        guard !validFiles.isEmpty else {
            throw DomainError.noValidFiles
        }

        return validFiles
    }

    func getOrganizationId() async throws -> Int {
        guard let organizationId = await bridge?.callFunction(GetCurrentOrganizationId()),
              organizationId > 0 else {
            throw DomainError.invalidOrganizationId
        }

        return organizationId
    }
}
