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
import EuriaCoreUI
import EuriaResources
import SwiftUI
import WidgetKit

extension View {
    @ViewBuilder
    func containerBackgroundForWidget(color: Color) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget) {
                color
            }
        } else {
            background(color)
        }
    }
}

struct QuickActionsWidgetView: View {
    var body: some View {
        ZStack {
            VStack(spacing: IKPadding.small) {
                NewConversationLinkView(url: DeeplinkConstants.newChatURL)

                HStack {
                    CircleIconLinkView(image: Image(systemName: "clock"), url: DeeplinkConstants.ephemeralURL)
                    Spacer()
                    CircleIconLinkView(image: Image(systemName: "waveform"), url: DeeplinkConstants.speechURL)
                }
            }
        }
        .padding(IKPadding.huge)
    }
}

struct QuickActionsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "EuriaWidget", provider: QuickActionsProvider()) { _ in
            QuickActionsWidgetView()
                .containerBackgroundForWidget(color: EuriaResourcesAsset.Colors.background.swiftUIColor)
        }
        .configurationDisplayName("Euria")
        .description("Description")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@available(iOSApplicationExtension 17.0, *)
#Preview(as: .systemSmall) {
    QuickActionsWidget()
} timeline: {
    QuickActionsEntry(date: .now)
}
