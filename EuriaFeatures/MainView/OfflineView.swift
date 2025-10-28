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

import DesignSystem
import EuriaResources
import Foundation
import SwiftUI

public struct OfflineView: View {
    public init() {}
    public var body: some View {
        ZStack {
            EuriaResourcesAsset.Images.onboardingBlurLeft.swiftUIImage
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
                .frame(maxHeight: .infinity, alignment: .top)

            VStack(spacing: IKPadding.huge) {
                EuriaResourcesAsset.Images.noNetwork.swiftUIImage

                VStack(spacing: IKPadding.medium) {
                    Text(EuriaResourcesStrings.noNetworkTitle)
                        .font(.Euria.title)
                        .foregroundStyle(EuriaResourcesAsset.Colors.textPrimary.swiftUIColor)
                    Text(EuriaResourcesStrings.noNetworkDescription)
                        .font(.Euria.body)
                        .foregroundStyle(EuriaResourcesAsset.Colors.textSecondary.swiftUIColor)
                }
            }
            .multilineTextAlignment(.center)
            .padding(IKPadding.medium)
        }
    }
}

#Preview {
    OfflineView()
}
