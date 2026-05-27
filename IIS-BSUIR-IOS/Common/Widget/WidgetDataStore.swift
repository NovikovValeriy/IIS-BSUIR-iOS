//
//  WidgetDataStore.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

struct WidgetDataStore {
    static let appGroupID = "group.by.bsuir.iis"
    private static let snapshotKey = "widget.snapshot"

    static func save(_ snapshot: WidgetScheduleSnapshot) {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotKey)
    }

    static func load() -> WidgetScheduleSnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: snapshotKey) else { return nil }
        return try? JSONDecoder().decode(WidgetScheduleSnapshot.self, from: data)
    }

    static func clear() {
        UserDefaults(suiteName: appGroupID)?.removeObject(forKey: snapshotKey)
    }
}
