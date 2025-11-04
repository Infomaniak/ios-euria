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

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry { Entry(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(Entry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        completion(Timeline(entries: [Entry(date: .now)], policy: .atEnd))
    }
}

struct Entry: TimelineEntry { let date: Date }

private struct SearchLinkBar: View {
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

private struct CircleIcon: View {
    var size: CGFloat = 60
    let image: Image
    let url: URL

    var body: some View {
        Link(destination: url) {
            ZStack {
                Circle()
                    .fill(EuriaResourcesAsset.Colors.disabledPrimary.swiftUIColor)
                    .frame(width: size, height: size)

                image
                    .foregroundStyle(.white)
                    .font(.system(size: IKPadding.large, weight: .semibold))
            }
            .contentShape(Circle())
        }
    }
}

struct widgetEntryView: View {
    var body: some View {
        ZStack {
            VStack(spacing: IKPadding.small) {
                SearchLinkBar(url: DeeplinkConstants.newChatURL)

                HStack {
                    CircleIcon(image: Image(systemName: "clock"), url: DeeplinkConstants.ephemeralURL)
                    Spacer()
                    CircleIcon(image: Image(systemName: "waveform"), url: DeeplinkConstants.speechURL)
                }
            }
        }
        .padding(IKPadding.huge)
    }
}

struct EuriaWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "EuriaWidget", provider: Provider()) { _ in
            makeEuriaWidget()
        }
        .configurationDisplayName("Euria")
        .description("Description")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@MainActor
@ViewBuilder
func makeEuriaWidget() -> some View {
    if #available(iOS 17.0, *) {
        widgetEntryView()
            .containerBackground(for: .widget) {
                Color(EuriaResourcesAsset.Colors.background.swiftUIColor)
            }
    } else {
        widgetEntryView()
            .appBackground()
    }
}

@available(iOSApplicationExtension 17.0, *)
#Preview(as: .systemSmall) {
    EuriaWidget()
} timeline: {
    Entry(date: .now)
}
