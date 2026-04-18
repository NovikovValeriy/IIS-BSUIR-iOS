//
//  UserDefaultsStorage.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 17.04.26.
//

import Foundation

final class UserDefaultsStorage: StorageProtocol {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func value<T: Codable>(for key: StorageKey) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func setValue<T: Codable>(_ value: T, for key: StorageKey) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key.rawValue)
    }

    func removeValue(for key: StorageKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
}
