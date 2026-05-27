//
//  NotificationServiceProtocol.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

protocol NotificationServiceProtocol {
    /// Requests notification permission. Returns `true` if granted.
    func requestAuthorization() async throws -> Bool
    /// Schedules (or replaces) a notification for the given lesson.
    func scheduleNotification(
        for lesson: Lesson,
        weekday: String,
        mode: NotificationMode,
        minutesBefore: Int
    ) async throws
    /// Cancels the pending notification with the given identifier.
    func cancelNotification(id: String) async
    /// Returns all lesson notifications currently pending in the system queue.
    func pendingNotifications() async -> [ScheduledLessonNotification]
    /// Returns whether a notification for the given ID is in the pending queue.
    func isScheduled(notificationId: String) async -> Bool
    /// Deterministic ID for a lesson + weekday pair.
    func notificationId(for lesson: Lesson, weekday: String) -> String
}
