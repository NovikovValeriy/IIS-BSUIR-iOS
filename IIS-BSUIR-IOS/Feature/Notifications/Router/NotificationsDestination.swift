//
//  NotificationsDestination.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

enum NotificationsDestination: Hashable {
    case notificationDetail(id: String)
}

enum NotificationsSheet: Identifiable {
    case filterOptions

    var id: String { "\(self)" }
}
