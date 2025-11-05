//
//  NewConversationLinkView.swift
//  EuriaWidget
//
//  Created by Valentin Perignon on 05.11.2025.
//

import DesignSystem
import EuriaResources
import SwiftUI

struct NewConversationLinkView: View {
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack {
                EuriaResourcesAsset.Images.widgetEuria.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: IKPadding.large, height: IKPadding.large)

                Spacer()
            }
            .padding(.horizontal, IKPadding.medium)
            .padding(.vertical, IKPadding.small)
            .background(
                RoundedRectangle(cornerRadius: IKPadding.large, style: .continuous)
                    .fill(EuriaResourcesAsset.Colors.disabledPrimary.swiftUIColor)
            )
        }
    }
}

#Preview {
    NewConversationLinkView(url: URL(string: "https://euria.infomaniak.com")!)
}
