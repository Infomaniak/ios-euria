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

public struct ImportHelper {
    public let importUUID: String
    public let importURL: URL

    public var importedFileURLs: [URL] {
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(
            at: importURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else {
            return []
        }
        return contents
    }

    public init(baseURL: URL) {
        self.init(baseURL: baseURL, importUUID: UUID().uuidString)
    }

    public init(baseURL: URL, importUUID: String) {
        self.importUUID = importUUID
        importURL = baseURL
            .appending(path: "imports", directoryHint: .isDirectory)
            .appending(path: importUUID, directoryHint: .isDirectory)
    }

    public func moveURLsToImportDirectory(_ urls: [URL]) async throws {
        let fileManager = FileManager.default

        try fileManager.createDirectory(at: importURL, withIntermediateDirectories: true)

        for url in urls {
            let destinationURL = importURL.appending(path: url.lastPathComponent)
            try fileManager.moveItem(at: url, to: destinationURL)
        }
    }
}
