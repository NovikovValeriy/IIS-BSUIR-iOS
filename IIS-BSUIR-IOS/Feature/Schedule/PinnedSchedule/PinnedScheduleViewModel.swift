//
//  PinnedScheduleViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 17.04.26.
//

import Foundation
import WidgetKit

@MainActor
final class PinnedScheduleViewModel: ScheduleViewModel {
    private let pinnedScheduleService: any PinnedScheduleServiceProtocol

    @ObservationIgnored
    private lazy var lessonDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private let russianWeekdays = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]

    init(
        router: ScheduleRouter,
        scheduleService: any ScheduleServiceProtocol,
        pinnedScheduleService: any PinnedScheduleServiceProtocol,
        storage: any StorageProtocol,
        cacheService: (any ScheduleCacheServiceProtocol)? = nil
    ) {
        self.pinnedScheduleService = pinnedScheduleService
        super.init(router: router, scheduleService: scheduleService, storage: storage, cacheService: cacheService)
    }

    // MARK: - Lifecycle

    override func onAppear() {
        super.onAppear()
        guard let subject = pinnedScheduleService.subject, selectedSubject == nil else { return }
        beginLoadingSubject(subject)
    }

    override var navigationTitle: String {
        selectedSubject?.displayName ?? String(localized: "schedule.pinned.title")
    }

    // MARK: - Pinned subject sync
    func pinnedSubjectDidChange(to subject: ScheduleSubject?) {
        guard subject != selectedSubject else { return }
        if let subject {
            beginLoadingSubject(subject)
        } else {
            unloadSubject()
        }
        router.popToRoot()
    }

    // MARK: - Widget snapshot

    override func scheduleDidUpdate(_ schedule: Schedule, for subject: ScheduleSubject) {
        guard let week = currentSemesterWeek else { return }
        let snapshot = buildWidgetSnapshot(schedule: schedule, subject: subject, currentSemesterWeek: week)
        WidgetDataStore.save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Deep link navigation

    func navigateToLesson(subject: String, startTime: String, weekday: String) {
        guard let schedule else { return }
        let weekdayLessons = schedule.weeklyLessons[weekday] ?? []
        guard let lesson = weekdayLessons.first(where: {
            ($0.subject == subject || $0.subjectFullName == subject) && $0.startTime == startTime
        }) else { return }
        router.push(.lessonDetail(lesson, weekday: weekday))
    }

    // MARK: - Private

    private func buildWidgetSnapshot(
        schedule: Schedule,
        subject: ScheduleSubject,
        currentSemesterWeek: Int
    ) -> WidgetScheduleSnapshot {
        let calendar = Calendar.current
        let today = Date()

        let weekdayComponent = calendar.component(.weekday, from: today)
        let weekdayIndex = weekdayComponent - 2
        guard weekdayIndex >= 0, weekdayIndex < russianWeekdays.count else {
            return WidgetScheduleSnapshot(subjectName: subject.displayName, lessonsToday: [], generatedAt: today)
        }
        let weekday = russianWeekdays[weekdayIndex]

        let cycleWeek = ((currentSemesterWeek - 1) % 4) + 1
        let todayStart = calendar.startOfDay(for: today)

        let todayLessons: [WidgetLesson] = (schedule.weeklyLessons[weekday] ?? []).compactMap { lesson in
            guard !lesson.announcement else { return nil }

            if let weeks = lesson.weekNumber, !weeks.isEmpty {
                guard weeks.contains(cycleWeek) else { return nil }
            }

            if let startStr = lesson.startLessonDate, let startD = lessonDateFormatter.date(from: startStr) {
                guard todayStart >= calendar.startOfDay(for: startD) else { return nil }
            }
            if let endStr = lesson.endLessonDate, let endD = lessonDateFormatter.date(from: endStr) {
                guard todayStart <= calendar.startOfDay(for: endD) else { return nil }
            }

            let timeParts = lesson.startTime.split(separator: ":").compactMap { Int($0) }
            guard timeParts.count == 2,
                  let startDate = calendar.date(bySettingHour: timeParts[0], minute: timeParts[1], second: 0, of: today)
            else { return nil }

            return WidgetLesson(
                id: "lesson_\(lesson.subject ?? "")_\(weekday)_\(lesson.startTime)_\(lesson.numSubgroup)",
                subject: lesson.subject ?? lesson.subjectFullName ?? "—",
                lessonType: lesson.lessonTypeAbbrev,
                startTime: lesson.startTime,
                endTime: lesson.endTime,
                room: lesson.auditories.first,
                teacherName: lesson.teachers.first?.shortName,
                weekday: weekday,
                startDate: startDate
            )
        }
        .sorted { $0.startDate < $1.startDate }

        return WidgetScheduleSnapshot(
            subjectName: subject.displayName,
            lessonsToday: todayLessons,
            generatedAt: today
        )
    }
}
