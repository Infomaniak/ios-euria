//
//  ShortcutsProvider.swift
//  EuriaWidget
//
//  Created by Valentin Perignon on 05.11.2025.
//

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
