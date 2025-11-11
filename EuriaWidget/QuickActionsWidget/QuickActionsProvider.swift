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

import WidgetKit

struct QuickActionsProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickActionsEntry {
        QuickActionsEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickActionsEntry) -> Void) {
        completion(QuickActionsEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickActionsEntry>) -> Void) {
        completion(Timeline(entries: [QuickActionsEntry(date: .now)], policy: .never))
    }
}

struct QuickActionsEntry: TimelineEntry {
    let date: Date
}
