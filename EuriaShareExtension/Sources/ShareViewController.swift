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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openMainApp()
    }

    private func openMainApp() {
        guard let url = URL(string: "euria://import-image") else { return }
        handleShare()
        openURL(url)
        close()
    }

    func openURL(_ url: URL) {
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
              let container = FileManager.default
              .containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)
        else {
            close()
            return
        }

       
    }

    private func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
