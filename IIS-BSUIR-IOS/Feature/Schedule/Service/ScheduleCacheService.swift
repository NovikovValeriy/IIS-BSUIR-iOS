//
//  ScheduleCacheService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 03.05.26.
//

import Foundation
import SwiftData

protocol ScheduleCacheServiceProtocol: AnyObject {
    func loadCachedSchedule(for subject: ScheduleSubject) -> Schedule?
    func saveSchedule(_ schedule: Schedule, for subject: ScheduleSubject)
}

@MainActor
final class ScheduleCacheService: ScheduleCacheServiceProtocol {
    private let modelContext: ModelContext

    @ObservationIgnored private let encoder = JSONEncoder()
    @ObservationIgnored private let decoder = JSONDecoder()

    init(modelContainer: ModelContainer) {
        self.modelContext = modelContainer.mainContext
    }

    func loadCachedSchedule(for subject: ScheduleSubject) -> Schedule? {
        let key = cacheKey(for: subject)
        guard let entry = fetchEntry(forKey: key) else { return nil }
        return try? decoder.decode(Schedule.self, from: entry.scheduleData)
    }

    func saveSchedule(_ schedule: Schedule, for subject: ScheduleSubject) {
        guard let data = try? encoder.encode(schedule) else { return }
        let key = cacheKey(for: subject)
        if let existing = fetchEntry(forKey: key) {
            existing.scheduleData = data
            existing.cachedAt = .now
        } else {
            modelContext.insert(CachedScheduleEntry(subjectKey: key, scheduleData: data))
        }
        try? modelContext.save()
    }

    // MARK: - Private

    private func cacheKey(for subject: ScheduleSubject) -> String {
        switch subject {
        case .group(let group): return "group:\(group.name)"
        case .teacher(let teacher): return "teacher:\(teacher.urlId)"
        }
    }

    private func fetchEntry(forKey key: String) -> CachedScheduleEntry? {
        let predicate = #Predicate<CachedScheduleEntry> { $0.subjectKey == key }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }
}
