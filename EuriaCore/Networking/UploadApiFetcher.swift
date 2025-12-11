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
import InfomaniakCore

struct UploadApiFetcher {
    let apiFetcher: ApiFetcher
    let organizationId: Int

    enum DomainError: Error {
        case apiError(rawJson: String)
        case noData
    }

    init(apiFetcher: ApiFetcher, organizationId: Int) {
        self.apiFetcher = apiFetcher
        self.organizationId = organizationId
    }

    func uploadFile(importedFile: ImportedFile) async throws -> FileUploadResult {
        let uploadRequest = apiFetcher.authenticatedRequest(.uploadFile(organizationId: organizationId), method: .post)
        return try await withCheckedThrowingContinuation { continuation in
            apiFetcher.authenticatedSession.upload(multipartFormData: { formData in
                                                       formData.append(importedFile.fileURL, withName: "file")
                                                   },
                                                   with: uploadRequest.convertible)
                .validate()
                .responseDecodable(of: ApiResponse<FileUploadResult>.self, decoder: apiFetcher.decoder) { response in
                    switch response.result {
                    case .success(let apiResponse):
                        if let result = apiResponse.data {
                            continuation.resume(returning: result)
                        } else if let rawJsonData = response.data,
                                  let rawJson = String(data: rawJsonData, encoding: .utf8) {
                            continuation.resume(throwing: DomainError.apiError(rawJson: rawJson))
                        } else {
                            continuation.resume(throwing: DomainError.noData)
                        }
                    case .failure(let error):
                        if let rawJsonData = response.data,
                           let rawJson = String(data: rawJsonData, encoding: .utf8) {
                            continuation.resume(throwing: DomainError.apiError(rawJson: rawJson))
                        } else {
                            continuation.resume(throwing: error)
                        }
                    }
                }
        }
    }
}
