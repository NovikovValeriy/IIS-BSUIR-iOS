//
//  SubgroupFilter.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 17.04.26.
//

enum SubgroupFilter: String, CaseIterable, Codable {
    case all
    case first
    case second

    /// The `numSubgroup` value that this filter targets, or nil for "all".
    var targetSubgroup: Int? {
        switch self {
        case .all: return nil
        case .first: return 1
        case .second: return 2
        }
    }
}
