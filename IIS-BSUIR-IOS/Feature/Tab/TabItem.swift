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
        case .pinnedSchedule: return "tab.pinned_schedule".localized()
        case .schedule: return "tab.schedule".localized()
        case .profile: return "tab.profile".localized()
        case .directory: return "tab.directory".localized()
        case .settings: return "tab.settings".localized()
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
