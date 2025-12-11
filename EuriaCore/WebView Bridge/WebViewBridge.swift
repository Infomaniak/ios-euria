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

public protocol JSMessage<Result> {
    associatedtype Result
    var message: String { get }
}

public protocol WebViewBridge: AnyObject {
    @discardableResult
    func sendMessage<M: JSMessage>(_ message: M) async -> M.Result?
}

public struct GoToDestinationMessage: JSMessage {
    public typealias Result = Void

    public let message: String

    public init(destination: String) {
        message = "goTo(\"\(destination)\")"
    }
}

public struct PrepareFilesForUploadMessage: JSMessage {
    public typealias Result = [String]

    public let message: String

    init(files: [ImportedFile]) {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(files),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            message = "prepareFilesForUpload([])"
            return
        }

        message = "prepareFilesForUpload(\(jsonString))"
    }
}

public struct GetCurrentOrganizationId: JSMessage {
    public typealias Result = Int

    public let message = "getCurrentOrganizationId()"
}

public struct FileUploadDone: JSMessage {
    public typealias Result = Void

    public let message: String

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
            message = "fileUploadDone({})"
            return
        }
        message = "fileUploadDone(\(jsonString))"
    }
}

public struct FileUploadError: JSMessage {
    public typealias Result = Void

    public let message: String

    public init(ref: String, error: String) {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(FileUploadErrorJsResponse(ref: ref, error: error)),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            message = "fileUploadError({})"
            return
        }
        message = "fileUploadError(\(jsonString))"
    }
}
