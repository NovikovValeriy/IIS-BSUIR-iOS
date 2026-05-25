//
//  DepartmentCacheService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import Foundation
import SwiftData

@MainActor
final class DepartmentCacheService {
    private let modelContext: ModelContext

    @ObservationIgnored private let encoder = JSONEncoder()
    @ObservationIgnored private let decoder = JSONDecoder()

    init(modelContainer: ModelContainer) {
        self.modelContext = modelContainer.mainContext
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let entry = fetchEntry(forKey: key) else { return nil }
        return try? decoder.decode(type, from: entry.data)
    }

    func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        if let existing = fetchEntry(forKey: key) {
            existing.data = data
            existing.cachedAt = .now
        } else {
            modelContext.insert(CachedDepartmentEntry(key: key, data: data))
        }
        try? modelContext.save()
    }

    private func fetchEntry(forKey key: String) -> CachedDepartmentEntry? {
        let predicate = #Predicate<CachedDepartmentEntry> { $0.key == key }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }
}
