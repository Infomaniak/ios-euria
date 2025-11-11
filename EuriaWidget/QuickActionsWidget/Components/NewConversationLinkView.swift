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
import EuriaCore
import EuriaResources
import SwiftUI

extension Image {
    @ViewBuilder
    func widgetFullColorRenderingMode() -> some View {
        if #available(iOS 26.0, *) {
            widgetAccentedRenderingMode(.fullColor)
        } else {
            self
        }
    }
}

struct NewConversationLinkView: View {
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode

    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 4) {
                EuriaResourcesAsset.Images.euriaLogo.swiftUIImage
                    .resizable()
                    .widgetFullColorRenderingMode()
                    .scaledToFit()

                Text("Euria")
                    .fontWeight(.bold)
                    .foregroundStyle(EuriaResourcesAsset.Colors.widgetTextPrimaryColor.swiftUIColor)
                    .minimumScaleFactor(0.5)
            }
            .padding(IKPadding.small)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                Capsule()
                    .fill(Color.buttonColor(in: widgetRenderingMode))
            }
        }
    }
}
