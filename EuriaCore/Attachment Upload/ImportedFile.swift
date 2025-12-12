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

public struct ImportedFile: Encodable, Sendable {
    let ref: String
    let name: String
    let mimeType: String
    let size: Int64

    let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL

        ref = UUID().uuidString
        name = fileURL.lastPathComponent
        do {
            let resourceValues = try fileURL.resourceValues(forKeys: [.contentTypeKey, .fileSizeKey])
            mimeType = resourceValues.contentType?.preferredMIMEType ?? "application/octet-stream"
            size = Int64(resourceValues.fileSize ?? 0)
        } catch {
            mimeType = "application/octet-stream"
            size = 0
        }
    }

    enum CodingKeys: String, CodingKey {
        case ref
        case name
        case mimeType
        case size
    }
}
