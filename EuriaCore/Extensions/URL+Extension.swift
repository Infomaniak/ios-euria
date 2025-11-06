//
//  URL+Extension.swift
//  EuriaCore
//
//  Created by Valentin Perignon on 06.11.2025.
//

import Foundation

public extension URL {
    static func temporaryDownloadsDirectory() throws -> URL {
        let temporaryFolder = URL.temporaryDirectory.appending(path: "/euria_downloads", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: temporaryFolder, withIntermediateDirectories: true)
        return temporaryFolder
    }
}
