//
//  NotificationsViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

@Observable
@MainActor
final class NotificationsViewModel {
    private let router: NotificationsRouter

    init(router: NotificationsRouter) {
        self.router = router
    }

    func didTapNotification(id: String) {
        router.push(.notificationDetail(id: id))
    }
}
