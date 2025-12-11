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

public protocol JSFunction<Result> {
    associatedtype Result
    var declaration: String { get }
}

public struct GoToDestination: JSFunction {
    public typealias Result = Void

    public let declaration: String

    public init(destination: String) {
        declaration = "goTo(\"\(destination)\")"
    }
}

public struct PrepareFilesForUpload: JSFunction {
    public typealias Result = [String]

    public let declaration: String

    init(files: [ImportedFile]) {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(files),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            declaration = "prepareFilesForUpload([])"
            return
        }

        declaration = "prepareFilesForUpload(\(jsonString))"
    }
}

public struct GetCurrentOrganizationId: JSFunction {
    public typealias Result = Int

    public let declaration = "getCurrentOrganizationId()"
}

public struct FileUploadDone: JSFunction {
    public typealias Result = Void

    public let declaration: String

    public init(ref: String, remoteId: String, name: String, mimeType: String) {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(
            FileUploadSucceedJsResponse(
                ref: ref,
                id: remoteId,
                name: name,
                mimeType: mimeType
            )),
            let jsonString = String(data: jsonData, encoding: .utf8) else {
            declaration = "fileUploadDone({})"
            return
        }
        declaration = "fileUploadDone(\(jsonString))"
    }
}

public struct FileUploadError: JSFunction {
    public typealias Result = Void

    public let declaration: String

    public init(ref: String, error: String) {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(FileUploadErrorJsResponse(ref: ref, error: error)),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            declaration = "fileUploadError({})"
            return
        }
        declaration = "fileUploadError(\(jsonString))"
    }
}
