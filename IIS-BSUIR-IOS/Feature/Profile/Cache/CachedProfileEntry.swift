//
//  CachedProfileEntry.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import Foundation
import SwiftData

@Model
final class CachedProfileEntry {
    @Attribute(.unique) var key: String
    var data: Data
    var cachedAt: Date

    init(key: String, data: Data, cachedAt: Date = .now) {
        self.key = key
        self.data = data
        self.cachedAt = cachedAt
    }
}
