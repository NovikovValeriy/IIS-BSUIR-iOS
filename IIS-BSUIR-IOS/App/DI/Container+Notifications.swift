//
//  Container+Notifications.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Factory

extension Container {
    var notificationService: Factory<any NotificationServiceProtocol> {
        self { NotificationService() }.shared
    }
}
