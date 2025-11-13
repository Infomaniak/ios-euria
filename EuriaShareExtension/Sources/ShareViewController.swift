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

import EuriaCore
import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openMainApp()
    }

    private func openMainApp() {
        guard let url = URL(string: "\(ShareExtensionConstants.scheme)://\(ShareExtensionConstants.shareImage)") else { return }
        handleShare()
        openURL(url)
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    @objc func openURL(_ url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url)
            }
            responder = responder?.next
        }
    }

    private func handleShare() {
        guard let item = (extensionContext?.inputItems.first as? NSExtensionItem),
              let attachment = item.attachments?
              .first(where: {
                  $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) ||
                      $0.hasItemConformingToTypeIdentifier(UTType.movie.identifier) ||
                      $0.hasItemConformingToTypeIdentifier(UTType.audio.identifier)
              }),
              let container = FileManager.default
              .containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)
        else {
            close()
            return
        }

        let sharedDirectory = container.appendingPathComponent("SharedData", isDirectory: true)
        try? FileManager.default.createDirectory(at: sharedDirectory, withIntermediateDirectories: true)

        let chosenTypeIdentifier: String
        if attachment.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            chosenTypeIdentifier = UTType.movie.identifier
        } else if attachment.hasItemConformingToTypeIdentifier(UTType.audio.identifier) {
            chosenTypeIdentifier = UTType.audio.identifier
        } else {
            chosenTypeIdentifier = UTType.image.identifier
        }

        attachment.loadFileRepresentation(forTypeIdentifier: chosenTypeIdentifier) { url, error in
            if let url {
                let destinationURL = sharedDirectory.appendingPathComponent(url.lastPathComponent)
                try? FileManager.default.removeItem(at: destinationURL)
                do {
                    try FileManager.default.copyItem(at: url, to: destinationURL)
                    if let sharedDefaults = UserDefaults(suiteName: Constants.appGroupIdentifier) {
                        sharedDefaults.set(destinationURL.path, forKey: "sharedMediaPath")
                    }
                } catch {
                    print("Error copying file: \(error.localizedDescription)")
                }
            }
        }
    }

    private func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
