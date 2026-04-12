//
//  TabItem.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

enum TabItem: Int, CaseIterable, Identifiable, Hashable {
    case schedule
    case profile
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .schedule: return "Schedule"
        case .profile: return "Profile"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .schedule: return "calendar"
        case .profile: return "person.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
