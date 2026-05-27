//
//  NotificationServiceProtocol.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

protocol NotificationServiceProtocol {
    func requestAuthorization() async throws -> Bool
    func scheduleNotification(
        for lesson: Lesson,
        weekday: String,
        mode: NotificationMode,
        minutesBefore: Int
    ) async throws
    func cancelNotification(id: String) async
    func pendingNotifications() async -> [ScheduledLessonNotification]
    func isScheduled(notificationId: String) async -> Bool
    func notificationId(for lesson: Lesson, weekday: String) -> String
}
