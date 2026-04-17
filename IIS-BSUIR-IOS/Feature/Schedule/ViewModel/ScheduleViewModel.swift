//
//  ScheduleViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

@Observable
@MainActor
final class ScheduleViewModel {
    private let router: ScheduleRouter
    private let scheduleService: any ScheduleServiceProtocol

    // Ordered Russian weekday names matching the API
    let weekdayOrder = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]

    var groups: [GroupModel] = []
    var teachers: [Teacher] = []
    var selectedSubject: ScheduleSubject?
    var lessons: [String: [Lesson]] = [:]
    var isLoadingGroups = false
    var isLoadingTeachers = false
    var isLoadingSchedule = false
    var errorMessage: String?

    // MARK: - Display mode

    var displayMode: ScheduleDisplayMode = .timeline

    // MARK: - Subgroup filter

    var subgroupFilter: SubgroupFilter = .all {
        didSet { applySubgroupFilter() }
    }

    // MARK: - Timeline

    var timelineDays: [TimelineDay] = []
    private(set) var timelineExhausted = false

    private var schedule: Schedule?
    /// The current semester week number as returned by the API (e.g. 7).
    /// Used to anchor the 4-week cycle without relying on startDate arithmetic.
    private var currentSemesterWeek: Int?
    private var timelineLoadedUntil: Date = {
        Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    }()

    // MARK: - Date formatters
    @ObservationIgnored
    private lazy var weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    @ObservationIgnored
    private lazy var dayMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }()

    @ObservationIgnored
    private lazy var dayMonthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    // MARK: - Computed

    var navigationTitle: String {
        selectedSubject?.displayName ?? String(localized: "schedule.title")
    }

    /// When viewing a teacher's schedule, rows should show the group instead of the teacher.
    var showGroupsInRow: Bool {
        if case .teacher = selectedSubject { return true }
        return false
    }

    init(router: ScheduleRouter, scheduleService: any ScheduleServiceProtocol) {
        self.router = router
        self.scheduleService = scheduleService
    }

    func onAppear() {
        Task { await loadGroups() }
        Task { await loadCurrentWeek() }
    }

    func didTapSelectGroup() {
        router.present(sheet: .groupPicker)
    }

    /// Called when the teacher tab in the picker becomes visible for the first time.
    func ensureTeachersLoaded() {
        guard teachers.isEmpty, !isLoadingTeachers else { return }
        isLoadingTeachers = true
        Task { await loadTeachers() }
    }

    func didSelectGroup(_ group: GroupModel) {
        didSelectSubject(.group(group))
    }

    func didSelectSubject(_ subject: ScheduleSubject) {
        selectedSubject = subject
        schedule = nil
        lessons = [:]
        timelineDays = []
        timelineExhausted = false
        subgroupFilter = .all
        timelineLoadedUntil = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
        router.dismissSheet()
        Task { await loadSchedule(for: subject) }
    }

    func didTapLesson(_ lesson: Lesson) {
        router.push(.lessonDetail(lesson))
    }

    func didTapFilter() {
        router.present(sheet: .filterOptions)
    }

    func didTapWeekPicker() {
        router.present(sheet: .weekPicker)
    }

    /// Called when switching to timeline mode if no days are loaded yet.
    func ensureTimelineGenerated() {
        guard let schedule, timelineDays.isEmpty else { return }
        timelineDays = buildTimeline(from: schedule, until: timelineLoadedUntil)
    }

    /// Extends the visible timeline window by 14 days and regenerates.
    func loadMoreTimelineDays() {
        guard let schedule else { return }
        timelineLoadedUntil = Calendar.current.date(
            byAdding: .day,
            value: 14,
            to: timelineLoadedUntil
        ) ?? timelineLoadedUntil
        timelineDays = buildTimeline(from: schedule, until: timelineLoadedUntil)
    }

    func sectionTitle(for day: TimelineDay) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayStart = calendar.startOfDay(for: day.date)

        var parts: [String] = []

        if dayStart == today {
            parts.append(String(localized: "schedule.timeline.today"))
        } else if dayStart == calendar.date(byAdding: .day, value: 1, to: today) {
            parts.append(String(localized: "schedule.timeline.tomorrow"))
        }

        parts.append(weekdayFormatter.string(from: day.date))

        let sameYear = calendar.isDate(day.date, equalTo: Date(), toGranularity: .year)
        parts.append(sameYear
            ? dayMonthFormatter.string(from: day.date)
            : dayMonthYearFormatter.string(from: day.date))

        if let week = day.cycleWeek {
            parts.append(String(localized: "schedule.timeline.week \(week)"))
        }

        return parts.joined(separator: ", ")
    }

    // MARK: - Private

    private func loadGroups() async {
        guard groups.isEmpty else { return }
        isLoadingGroups = true
        errorMessage = nil
        do {
            groups = try await scheduleService.fetchGroups()
        } catch {
            errorMessage = String(localized: "schedule.error.load_groups")
        }
        isLoadingGroups = false
    }

    private func loadTeachers() async {
        do {
            teachers = try await scheduleService.fetchTeachers()
        } catch {
            // Non-fatal: teacher tab will show an empty state
        }
        isLoadingTeachers = false
    }

    private func loadCurrentWeek() async {
        guard currentSemesterWeek == nil else { return }
        do {
            currentSemesterWeek = try await scheduleService.fetchCurrentWeek()
            // If a schedule is already loaded and the timeline is visible, refresh it
            if displayMode == .timeline, let schedule {
                timelineDays = buildTimeline(from: schedule, until: timelineLoadedUntil)
            }
        } catch {
            // Non-fatal: timeline falls back to showing all week-numbers if nil
        }
    }

    private func loadSchedule(for subject: ScheduleSubject) async {
        isLoadingSchedule = true
        errorMessage = nil
        do {
            let loaded = try await scheduleService.fetchSchedule(for: subject)
            schedule = loaded
            lessons = filteredLessons(loaded.weeklyLessons)
            if displayMode == .timeline {
                timelineDays = buildTimeline(from: loaded, until: timelineLoadedUntil)
            }
        } catch {
            errorMessage = String(localized: "schedule.error.load_schedule \(subject.displayName)")
            lessons = [:]
        }
        isLoadingSchedule = false
    }

    // MARK: - Subgroup filtering

    private func shouldInclude(lesson: Lesson) -> Bool {
        guard let target = subgroupFilter.targetSubgroup else { return true }
        return lesson.numSubgroup == 0 || lesson.numSubgroup == target
    }

    private func filteredLessons(_ raw: [String: [Lesson]]) -> [String: [Lesson]] {
        guard subgroupFilter.targetSubgroup != nil else { return raw }
        return raw.mapValues { $0.filter { shouldInclude(lesson: $0) } }
    }

    private func applySubgroupFilter() {
        guard let schedule else { return }
        lessons = filteredLessons(schedule.weeklyLessons)
        if displayMode == .timeline {
            timelineDays = buildTimeline(from: schedule, until: timelineLoadedUntil)
        }
    }

    // MARK: - Timeline generation

    private static let lessonDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private func buildTimeline(
        from schedule: Schedule,
        until endDate: Date
    ) -> [TimelineDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let semesterEnd = schedule.semesterEndDate.flatMap { Self.lessonDateFormatter.date(from: $0) }

        let iterEnd: Date
        if let semesterEnd {
            let semesterEndDay = calendar.startOfDay(for: semesterEnd)
            let requestedEnd = calendar.startOfDay(for: endDate)
            if requestedEnd >= semesterEndDay {
                iterEnd = semesterEndDay
                timelineExhausted = true
            } else {
                iterEnd = requestedEnd
                timelineExhausted = false
            }
        } else {
            iterEnd = calendar.startOfDay(for: endDate)
            timelineExhausted = false
        }

        guard today <= iterEnd else { return [] }

        var days: [TimelineDay] = []
        var current = today

        while current <= iterEnd {
            var dayLessons: [Lesson] = []

            // Recurring lessons from the weekly schedule
            if let weekdayName = russianWeekday(for: current),
               let recurringLessons = schedule.weeklyLessons[weekdayName] {

                let cycleWeek = cycleWeek(for: current)

                for lesson in recurringLessons {
                    // Filter by 4-week cycle number
                    if let weeks = lesson.weekNumber {
                        guard let cycleWeek, weeks.contains(cycleWeek) else { continue }
                    }

                    // Filter by lesson-level date range (e.g. lesson only valid for part of semester)
                    if let startStr = lesson.startLessonDate,
                       let startD = Self.lessonDateFormatter.date(from: startStr) {
                        guard current >= calendar.startOfDay(for: startD) else { continue }
                    }
                    if let endStr = lesson.endLessonDate,
                       let endD = Self.lessonDateFormatter.date(from: endStr) {
                        guard current <= calendar.startOfDay(for: endD) else { continue }
                    }

                    guard shouldInclude(lesson: lesson) else { continue }
                    dayLessons.append(lesson)
                }
            }

            // One-time lessons (exams and single-date lessons)
            let currentStr = Self.lessonDateFormatter.string(from: current)
            for exam in schedule.exams where exam.dateLesson == currentStr {
                guard shouldInclude(lesson: exam) else { continue }
                dayLessons.append(exam)
            }

            if !dayLessons.isEmpty {
                let sorted = dayLessons.sorted { $0.startTime < $1.startTime }
                days.append(TimelineDay(date: current, lessons: sorted, cycleWeek: cycleWeek(for: current)))
            }

            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        return days
    }

    /// Maps a date to the Russian weekday name used as a key in the API response.
    /// Returns nil for Sunday (not in the schedule).
    private func russianWeekday(for date: Date) -> String? {
        // Calendar.weekday: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
        let weekday = Calendar.current.component(.weekday, from: date)
        let index = weekday - 2  // Monday = 0, ..., Saturday = 5, Sunday = -1
        guard index >= 0, index < weekdayOrder.count else { return nil }
        return weekdayOrder[index]
    }

    /// Returns the 1-based position in the 4-week rotating cycle for a given date.
    /// Anchored using the API-provided `currentSemesterWeek` for today.
    /// Returns nil if the current week hasn't been fetched yet.
    private func cycleWeek(for date: Date) -> Int? {
        guard let currentSemesterWeek else { return nil }
        let calendar = Calendar.current
        let todayWeekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let targetWeekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let weekDiff = calendar.dateComponents([.weekOfYear], from: todayWeekStart, to: targetWeekStart).weekOfYear ?? 0
        let semesterWeekForDate = currentSemesterWeek + weekDiff
        // Guard against negative values (dates before semester start edge case)
        guard semesterWeekForDate > 0 else { return nil }
        return ((semesterWeekForDate - 1) % 4) + 1
    }
}
