//
//  LessonNotificationViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@Observable
@MainActor
final class LessonNotificationViewModel {
    let lesson: Lesson
    let weekday: String
    private let notificationService: any NotificationServiceProtocol

    private(set) var isEnabled = false
    private(set) var isLoading = false
    // Set to true when the OS permission dialog was denied
    private(set) var permissionDenied = false

    var selectedMode: NotificationMode = .weekly
    var minutesBefore: Int = 15

    var notificationId: String {
        notificationService.notificationId(for: lesson, weekday: weekday)
    }

    init(lesson: Lesson, weekday: String, notificationService: any NotificationServiceProtocol) {
        self.lesson = lesson
        self.weekday = weekday
        self.notificationService = notificationService
    }

    func dismissPermissionDenied() {
        permissionDenied = false
    }

    /// Replaces the active notification with current mode/minutesBefore settings.
    /// No-op if no notification is currently scheduled.
    func reschedule() async {
        guard isEnabled else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await notificationService.scheduleNotification(
                for: lesson,
                weekday: weekday,
                mode: selectedMode,
                minutesBefore: minutesBefore
            )
        } catch {
            // Leave state unchanged on failure
        }
    }

    func load() async {
        isLoading = true
        isEnabled = await notificationService.isScheduled(notificationId: notificationId)
        isLoading = false
    }

    func toggle() async {
        isLoading = true
        defer { isLoading = false }

        if isEnabled {
            await notificationService.cancelNotification(id: notificationId)
            isEnabled = false
        } else {
            do {
                let granted = try await notificationService.requestAuthorization()
                guard granted else {
                    permissionDenied = true
                    return
                }
                try await notificationService.scheduleNotification(
                    for: lesson,
                    weekday: weekday,
                    mode: selectedMode,
                    minutesBefore: minutesBefore
                )
                isEnabled = true
            } catch {
                // Scheduling failed — leave isEnabled = false, no crash
            }
        }
    }
}
