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
    public weak var bridge: WebViewBridge?

    public init() {}

    public func handleImportSession(uuid: String) {
        Task {
            await handleImportSession(uuid: uuid)
        }
    }

    func handleImportSession(uuid: ImportHelper.ImportSessionUUID) async {
        guard let containerURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) else {
            return
        }

        let importHelper = ImportHelper(baseURL: containerURL, importUUID: uuid)
        await prepareUploadSessionWith(importHelper: importHelper)
    }

    func prepareUploadSessionWith(importHelper: ImportHelper) async {
        let importedFileURLs = importHelper.importedFileURLs
        let importedFiles: [ImportedFile] = importedFileURLs.map { ImportedFile(fileURL: $0) }

        guard let validFileUUIDs = await bridge?.sendMessage(PrepareFilesForUploadMessage(files: importedFiles)) else {
            return
        }

        let validFiles = importedFiles.filter { validFileUUIDs.contains($0.ref) }

        guard !validFiles.isEmpty else {
            return
        }


    }
}
