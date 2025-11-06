//
//  NewConversationLinkView.swift
//  EuriaWidget
//
//  Created by Valentin Perignon on 05.11.2025.
//

import DesignSystem
import EuriaResources
import SwiftUI
import EuriaCore

struct NewConversationLinkView: View {
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 4) {
                EuriaResourcesAsset.Images.euriaLogo.swiftUIImage
                    .resizable()
                    .scaledToFit()

                Text("Euria")
                    .fontWeight(.bold)
                    .foregroundStyle(EuriaResourcesAsset.Colors.widgetTextPrimaryColor.swiftUIColor)
                    .minimumScaleFactor(0.5)
            }
            .padding(IKPadding.small)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(
                Capsule()
                    .fill(EuriaResourcesAsset.Colors.widgetButtonColor.swiftUIColor)
            )
        }
    }
}
