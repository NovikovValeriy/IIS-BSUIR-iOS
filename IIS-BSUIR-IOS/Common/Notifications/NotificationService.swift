//
//  NotificationService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import UserNotifications
import Foundation

enum NotificationError: LocalizedError {
    case invalidTime
    case invalidWeekday
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .invalidTime: return "Invalid lesson time format."
        case .invalidWeekday: return "Unknown weekday."
        case .permissionDenied: return String(localized: "notifications.permission_denied")
        }
    }
}

final class NotificationService: NotificationServiceProtocol {
    private let center = UNUserNotificationCenter.current()

    // Russian weekday name → Gregorian Calendar weekday (1 = Sunday … 7 = Saturday)
    private let russianWeekdayIndex: [String: Int] = [
        "Воскресенье": 1,
        "Понедельник": 2,
        "Вторник": 3,
        "Среда": 4,
        "Четверг": 5,
        "Пятница": 6,
        "Суббота": 7
    ]

    func requestAuthorization() async throws -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        @unknown default:
            return false
        }
    }

    func scheduleNotification(
        for lesson: Lesson,
        weekday: String,
        mode: NotificationMode,
        minutesBefore: Int
    ) async throws {
        let id = notificationId(for: lesson, weekday: weekday)
        center.removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = lesson.subjectFullName ?? lesson.subject ?? String(localized: "lesson.detail.default_title")
        var bodyParts: [String] = []
        if let type = lesson.lessonTypeAbbrev { bodyParts.append(type) }
        if !lesson.auditories.isEmpty { bodyParts.append(lesson.auditories.joined(separator: ", ")) }
        bodyParts.append(lesson.startTime)
        content.body = bodyParts.joined(separator: " · ")
        content.sound = .default

        let trigger = try buildTrigger(
            startTime: lesson.startTime,
            weekday: weekday,
            minutesBefore: minutesBefore,
            mode: mode
        )

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    func cancelNotification(id: String) async {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    func pendingNotifications() async -> [ScheduledLessonNotification] {
        let requests = await center.pendingNotificationRequests()
        return requests.compactMap { request in
            guard request.identifier.hasPrefix("lesson_") else { return nil }

            let isWeekly: Bool
            let triggerTime: String

            if let calTrigger = request.trigger as? UNCalendarNotificationTrigger {
                isWeekly = calTrigger.repeats
                let components = calTrigger.dateComponents
                triggerTime = String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
            } else if let intervalTrigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                isWeekly = false
                let fireDate = Date(timeIntervalSinceNow: intervalTrigger.timeInterval)
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                triggerTime = formatter.string(from: fireDate)
            } else {
                isWeekly = false
                triggerTime = "—"
            }

            return ScheduledLessonNotification(
                id: request.identifier,
                title: request.content.title,
                body: request.content.body,
                triggerTime: triggerTime,
                isWeekly: isWeekly
            )
        }
    }

    func isScheduled(notificationId: String) async -> Bool {
        let requests = await center.pendingNotificationRequests()
        return requests.contains { $0.identifier == notificationId }
    }

    func notificationId(for lesson: Lesson, weekday: String) -> String {
        let subject = (lesson.subject ?? "unknown")
            .replacingOccurrences(of: " ", with: "_")
        return "lesson_\(subject)_\(weekday)_\(lesson.startTime)_\(lesson.numSubgroup)"
    }

    // MARK: - Private

    private func buildTrigger(
        startTime: String,
        weekday: String,
        minutesBefore: Int,
        mode: NotificationMode
    ) throws -> UNNotificationTrigger {
        let timeParts = startTime.split(separator: ":").compactMap { Int($0) }
        guard timeParts.count == 2 else { throw NotificationError.invalidTime }

        var totalMinutes = timeParts[0] * 60 + timeParts[1] - minutesBefore
        // Wrap past midnight if minutesBefore pushes time before 00:00
        if totalMinutes < 0 { totalMinutes += 24 * 60 }
        let triggerHour = totalMinutes / 60
        let triggerMinute = totalMinutes % 60

        guard let weekdayInt = russianWeekdayIndex[weekday] else {
            throw NotificationError.invalidWeekday
        }

        switch mode {
        case .weekly:
            var components = DateComponents()
            components.weekday = weekdayInt
            components.hour = triggerHour
            components.minute = triggerMinute
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        case .once:
            var components = DateComponents()
            components.weekday = weekdayInt
            components.hour = triggerHour
            components.minute = triggerMinute
            components.second = 0
            guard let nextDate = Calendar.current.nextDate(
                after: Date(),
                matching: components,
                matchingPolicy: .nextTime
            ) else { throw NotificationError.invalidTime }
            let interval = max(nextDate.timeIntervalSinceNow, 1)
            return UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        }
    }
}
