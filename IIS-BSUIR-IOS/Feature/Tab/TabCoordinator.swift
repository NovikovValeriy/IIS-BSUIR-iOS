//
//  TabCoordinator.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation
import Observation

@Observable
@MainActor
final class TabCoordinator {
    var selectedTab: TabItem = .pinnedSchedule

    func select(_ tab: TabItem) {
        if selectedTab == tab {
            NotificationCenter.default.post(name: .popToRoot(for: tab), object: nil)
        } else {
            selectedTab = tab
        }
    }
}

extension Notification.Name {
    static func popToRoot(for tab: TabItem) -> Notification.Name {
        Notification.Name("popToRoot_\(tab.rawValue)")
    }
}
