//
//  CachedScheduleEntry.swift
//  IIS-BSUIR-IOS
//

import Foundation
import SwiftData

@Model
final class CachedScheduleEntry {
    @Attribute(.unique) var subjectKey: String
    var scheduleData: Data
    var cachedAt: Date

    init(subjectKey: String, scheduleData: Data, cachedAt: Date = .now) {
        self.subjectKey = subjectKey
        self.scheduleData = scheduleData
        self.cachedAt = cachedAt
    }
}
