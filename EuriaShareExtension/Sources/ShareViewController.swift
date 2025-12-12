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
import InfomaniakCore
import OSLog
import UIKit
import UniformTypeIdentifiers

extension NSItemProvider: @unchecked @retroactive Sendable {
    enum ErrorDomain: Error {
        /// The type needs dedicated handling
        case unsupportedUnderlyingType
    }

    public func importItem() async throws -> URL {
        switch underlyingType {
        case .isURL:
            let getURL = try ItemProviderURLRepresentation(from: self)
            let result = try await getURL.result.get()
            return result.url

        case .isText:
            let getText = try ItemProviderTextRepresentation(from: self)
            let resultURL = try await getText.result.get()
            return resultURL

        case .isImageData, .isCompressedData, .isMiscellaneous:
            let getFile = try ItemProviderFileRepresentation(from: self)
            let result = try await getFile.result.get()
            return result.url

        // Keep it for forward compatibility
        default:
            throw ErrorDomain.unsupportedUnderlyingType
        }
    }
}

// periphery:ignore - ShareViewController is triggered by the system.
final class ShareViewController: UIViewController {
    private lazy var progressContainerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    private lazy var progressView: UIActivityIndicatorView = {
        let progressView = UIActivityIndicatorView(style: .large)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressContainerView()

        Task {
            await handleSharedItems()
        }
    }

    private func setupProgressContainerView() {
        view.addSubview(progressContainerView)

        NSLayoutConstraint.activate([
            progressContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressContainerView.heightAnchor.constraint(equalToConstant: 300),
            progressContainerView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        progressContainerView.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor)
        ])

        progressView.startAnimating()
    }

    private func openURL(_ url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url)
                return
            }
            responder = responder?.next
        }
    }

    private func handleSharedItems() async {
        guard let extensionItems: [NSExtensionItem] = extensionContext?.inputItems.compactMap({ $0 as? NSExtensionItem }),
              !extensionItems.isEmpty else {
            close()
            return
        }

        let itemProviders: [NSItemProvider] = extensionItems.filteredItemProviders
        guard !itemProviders.isEmpty else {
            close()
            return
        }

        guard let containerURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) else {
            close()
            return
        }

        let possibleURLs: [URL?] = await itemProviders.asyncMap { itemProvider in
            do {
                let url = try await itemProvider.importItem()
                return url
            } catch {
                return nil
            }
        }

        let urls = possibleURLs.compactMap { $0 }
        guard !urls.isEmpty else {
            close()
            return
        }

        do {
            let importHelper = ImportHelper(baseURL: containerURL)

            try await importHelper.moveURLsToImportDirectory(urls)

            openURL(DeeplinkConstants.importURLFor(uuid: importHelper.importUUID))
        } catch {
            Logger.general.error("Failed to import URLs: \(error)")
        }
        close()
    }

    private func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
