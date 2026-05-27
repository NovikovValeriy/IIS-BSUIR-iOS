//
//  ScheduledNotificationsViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@Observable
@MainActor
final class ScheduledNotificationsViewModel {
    private let notificationService: any NotificationServiceProtocol

    private(set) var notifications: [ScheduledLessonNotification] = []
    private(set) var isLoading = false

    init(notificationService: any NotificationServiceProtocol) {
        self.notificationService = notificationService
    }

    func load() async {
        isLoading = true
        notifications = await notificationService.pendingNotifications()
        isLoading = false
    }

    func cancel(id: String) async {
        await notificationService.cancelNotification(id: id)
        notifications.removeAll { $0.id == id }
    }
}
