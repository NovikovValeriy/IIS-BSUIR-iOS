//
//  TabItem.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

enum TabItem: Int, CaseIterable, Identifiable, Hashable {
    case pinnedSchedule
    case schedule
    case profile
    case directory
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .pinnedSchedule: return String(localized: "tab.pinned_schedule")
        case .schedule: return String(localized: "tab.schedule")
        case .profile: return String(localized: "tab.profile")
        case .directory: return String(localized: "tab.directory")
        case .settings: return String(localized: "tab.settings")
        }
    }

    var systemImage: String {
        switch self {
        case .pinnedSchedule: return "pin.fill"
        case .schedule: return "magnifyingglass"
        case .profile: return "person.fill"
        case .directory: return "building.columns"
        case .settings: return "gearshape.fill"
        }
    }
}
