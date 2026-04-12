//
//  Container+Notifications.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Factory

extension Container {
    var notificationsRouter: Factory<NotificationsRouter> {
        self { @MainActor in NotificationsRouter() }.shared
    }

    var notificationsViewModel: Factory<NotificationsViewModel> {
        self { @MainActor in NotificationsViewModel(router: self.notificationsRouter()) }
    }
}
