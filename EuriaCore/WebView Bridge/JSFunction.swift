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
    var functionBody: String { get }
    var arguments: [String: Any] { get }
}

public extension JSFunction {
    var arguments: [String: Any] {
        [:]
    }
}

extension JSFunction {
    static func javaScriptArgument(from value: some Encodable) -> Any? {
        guard let data = try? JSONEncoder().encode(value) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
    }
}

public struct GoToDestination: JSFunction {
    public typealias Result = Void

    public let functionBody = "goTo(destination);"
    public let arguments: [String: Any]

    public init(destination: String) {
        arguments = ["destination": destination]
    }
}

public struct PrepareFilesForUpload: JSFunction {
    public typealias Result = [String]

    public let functionBody = "return prepareFilesForUpload(files);"
    public let arguments: [String: Any]

    init(files: [ImportedFile]) {
        arguments = ["files": Self.javaScriptArgument(from: files) ?? [Any]()]
    }
}

public struct GetCurrentOrganizationId: JSFunction {
    public typealias Result = Int

    public let functionBody = "return getCurrentOrganizationId();"
}

public struct FileUploadDone: JSFunction {
    public typealias Result = Void

    public let functionBody = "fileUploadDone(response);"
    public let arguments: [String: Any]

    public init(ref: String, remoteId: String, name: String, mimeType: String) {
        let response = FileUploadSucceedJsResponse(ref: ref, id: remoteId, name: name, mimeType: mimeType)
        arguments = ["response": Self.javaScriptArgument(from: response) ?? [String: Any]()]
    }
}

public struct FileUploadError: JSFunction {
    public typealias Result = Void

    public let functionBody = "fileUploadError(response);"
    public let arguments: [String: Any]

    public init(ref: String, error: String) {
        let response = FileUploadErrorJsResponse(ref: ref, error: error)
        arguments = ["response": Self.javaScriptArgument(from: response) ?? [String: Any]()]
    }
}

public struct EnableAppFeatures: JSFunction {
    public typealias Result = Void

    public let functionBody = "enableAppFeatures(features);"
    public let arguments: [String: Any]

    public init(features: [AppFeatures] = AppFeatures.allCases) {
        arguments = ["features": features.map(\.rawValue)]
    }
}
