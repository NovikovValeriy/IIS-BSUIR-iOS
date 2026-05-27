//
//  ScheduleViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation
import Network

// swiftlint:disable type_body_length
// swiftlint:disable file_length
@Observable
@MainActor
class ScheduleViewModel {
    let router: ScheduleRouter
    let scheduleService: any ScheduleServiceProtocol
    private let storage: (any StorageProtocol)?
    private let cacheService: (any ScheduleCacheServiceProtocol)?

    // Ordered Russian weekday names matching the API
    let weekdayOrder = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]

    var selectedSubject: ScheduleSubject?
    var lessons: [String: [Lesson]] = [:]
    var isLoadingSchedule = false
    var isOfflineFallback = false
    var errorMessage: String?

    // MARK: - Display mode

    var displayMode: ScheduleDisplayMode = .timeline {
        didSet { storage?.setValue(displayMode, for: .scheduleDisplayMode) }
    }

    // MARK: - Subgroup filter

    var subgroupFilter: SubgroupFilter = .all {
        didSet {
            applySubgroupFilter()
            storage?.setValue(subgroupFilter, for: .scheduleSubgroupFilter)
        }
    }

    // MARK: - Timeline

    var timelineDays: [TimelineDay] = []
    private(set) var timelineExhausted = false

    // MARK: - Exams

    var examsDays: [TimelineDay] = []

    private(set) var schedule: Schedule?
    /// The current semester week number as returned by the API (e.g. 7).
    /// Used to anchor the 4-week cycle without relying on startDate arithmetic.
    private(set) var currentSemesterWeek: Int?
    private var timelineLoadedUntil: Date = {
        Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    }()

    @ObservationIgnored
    private var loadScheduleTask: Task<Void, Never>?

    @ObservationIgnored
    private var pathMonitor: NWPathMonitor?

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

    @ObservationIgnored
    private lazy var lessonDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
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

    var canChangeSubject: Bool { false }

    // MARK: - Init

    init(
        router: ScheduleRouter,
        scheduleService: any ScheduleServiceProtocol,
        storage: (any StorageProtocol)? = nil,
        cacheService: (any ScheduleCacheServiceProtocol)? = nil
    ) {
        self.router = router
        self.scheduleService = scheduleService
        self.storage = storage
        self.cacheService = cacheService
        // Restore persisted preferences — assignments in init do not trigger didSet.
        self.displayMode = storage?.value(for: .scheduleDisplayMode) ?? .timeline
        self.subgroupFilter = storage?.value(for: .scheduleSubgroupFilter) ?? .all
    }

    deinit {
        pathMonitor?.cancel()
    }

    // MARK: - Lifecycle

    func onAppear() {
        Task { await loadCurrentWeek() }
        startNetworkMonitor()
    }

    // MARK: - Actions

    func didTapLesson(_ lesson: Lesson, weekday: String? = nil) {
        router.push(.lessonDetail(lesson, weekday: weekday))
    }

    func didTapRetry() {
        guard let subject = selectedSubject else { return }
        Task { await loadSchedule(for: subject) }
    }

    func didPullToRefresh() async {
        guard let subject = selectedSubject else { return }
        loadScheduleTask?.cancel()
        Task { await loadCurrentWeek() }
        await loadSchedule(for: subject)
    }

    /// Called when switching to timeline mode if no days are loaded yet.
    func ensureTimelineGenerated() {
        guard let schedule, timelineDays.isEmpty else { return }
        timelineDays = buildTimeline(from: schedule, until: timelineLoadedUntil)
    }

    /// Called when switching to exams mode if no days are loaded yet.
    func ensureExamsGenerated() {
        guard let schedule, examsDays.isEmpty else { return }
        examsDays = buildExamsTimeline(from: schedule)
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

    // MARK: - Override hooks

    /// Called after a schedule is applied (from network or cache) and when currentSemesterWeek changes.
    /// Override in subclasses to react to schedule updates without accessing private state.
    func scheduleDidUpdate(_ schedule: Schedule, for subject: ScheduleSubject) {}

    // MARK: - Internal (available to subclasses)

    /// Resets stale schedule state and kicks off loading a new subject.
    /// Pass `resetFilter: true` when the user actively selects a new subject.
    func beginLoadingSubject(_ subject: ScheduleSubject, resetFilter: Bool = false) {
        loadScheduleTask?.cancel()
        selectedSubject = subject
        schedule = nil
        lessons = [:]
        timelineDays = []
        examsDays = []
        timelineExhausted = false
        isOfflineFallback = false
        timelineLoadedUntil = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
        if resetFilter { subgroupFilter = .all }
        loadScheduleTask = Task { await loadSchedule(for: subject) }
    }

    /// Clears all schedule state without loading a new subject.
    func unloadSubject() {
        loadScheduleTask?.cancel()
        loadScheduleTask = nil
        selectedSubject = nil
        schedule = nil
        lessons = [:]
        timelineDays = []
        examsDays = []
        isOfflineFallback = false
        stopNetworkMonitor()
    }

    // MARK: - Private

    private func startNetworkMonitor() {
        guard pathMonitor == nil else { return }
        let monitor = NWPathMonitor()
        pathMonitor = monitor
        monitor.pathUpdateHandler = { [weak self] path in
            guard path.status == .satisfied else { return }
            Task { @MainActor [weak self] in self?.retryIfOffline() }
        }
        monitor.start(queue: .global(qos: .utility))
    }

    private func stopNetworkMonitor() {
        pathMonitor?.cancel()
        pathMonitor = nil
    }

    private func retryIfOffline() {
        guard isOfflineFallback || (errorMessage != nil && schedule == nil) else { return }
        guard let subject = selectedSubject else { return }
        loadScheduleTask?.cancel()
        Task { await loadCurrentWeek() }
        loadScheduleTask = Task { await loadSchedule(for: subject) }
    }

    private func loadSchedule(for subject: ScheduleSubject) async {
        defer { isLoadingSchedule = false }
        errorMessage = nil

        if let cached = cacheService?.loadCachedSchedule(for: subject) {
            applySchedule(cached)
        } else {
            isLoadingSchedule = true
        }

        do {
            let fresh = try await scheduleService.fetchSchedule(for: subject)
            guard !Task.isCancelled else { return }
            if schedule == nil || fresh != schedule {
                applySchedule(fresh)
            }
            cacheService?.saveSchedule(fresh, for: subject)
            isOfflineFallback = false
        } catch {
            guard !Task.isCancelled else { return }
            if schedule != nil {
                isOfflineFallback = true
            } else {
                errorMessage = String(localized: "schedule.error.load_schedule \(subject.displayName)")
                lessons = [:]
            }
        }
    }

    private func applySchedule(_ loaded: Schedule) {
        schedule = loaded
        lessons = filteredLessons(loaded.weeklyLessons)
        switch displayMode {
        case .timeline:
            timelineDays = buildTimeline(from: loaded, until: timelineLoadedUntil)
        case .exams:
            examsDays = buildExamsTimeline(from: loaded)
        case .weekly:
            break
        }
        if let selectedSubject {
            scheduleDidUpdate(loaded, for: selectedSubject)
        }
    }

    private func loadCurrentWeek() async {
        if currentSemesterWeek == nil, let cached: Int = storage?.value(for: .currentSemesterWeek) {
            currentSemesterWeek = cached
            if displayMode == .timeline, let schedule {
                timelineDays = buildTimeline(from: schedule, until: timelineLoadedUntil)
            }
            if let schedule, let selectedSubject {
                scheduleDidUpdate(schedule, for: selectedSubject)
            }
        }
        do {
            let fresh = try await scheduleService.fetchCurrentWeek()
            if fresh != currentSemesterWeek {
                currentSemesterWeek = fresh
                storage?.setValue(fresh, for: .currentSemesterWeek)
                if displayMode == .timeline, let schedule {
                    timelineDays = buildTimeline(from: schedule, until: timelineLoadedUntil)
                }
                if let schedule, let selectedSubject {
                    scheduleDidUpdate(schedule, for: selectedSubject)
                }
            }
        } catch {
            // Non-fatal — currentSemesterWeek may already be set from UserDefaults above
        }
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
        switch displayMode {
        case .timeline:
            timelineDays = buildTimeline(from: schedule, until: timelineLoadedUntil)
        case .exams:
            examsDays = buildExamsTimeline(from: schedule)
        case .weekly:
            break
        }
    }

    // MARK: - Timeline generation

    // swiftlint:disable cyclomatic_complexity
    private func buildTimeline(
        from schedule: Schedule,
        until endDate: Date
    ) -> [TimelineDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let semesterEnd = schedule.semesterEndDate.flatMap { lessonDateFormatter.date(from: $0) }

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
                       let startD = lessonDateFormatter.date(from: startStr) {
                        guard current >= calendar.startOfDay(for: startD) else { continue }
                    }
                    if let endStr = lesson.endLessonDate,
                       let endD = lessonDateFormatter.date(from: endStr) {
                        guard current <= calendar.startOfDay(for: endD) else { continue }
                    }

                    guard shouldInclude(lesson: lesson) else { continue }
                    dayLessons.append(lesson)
                }
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
    // swiftlint:enable cyclomatic_complexity

    private func buildExamsTimeline(from schedule: Schedule) -> [TimelineDay] {
        guard !schedule.exams.isEmpty else { return [] }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let iterEnd: Date
        if let endStr = schedule.examsEndDate,
           let endDate = lessonDateFormatter.date(from: endStr) {
            iterEnd = calendar.startOfDay(for: endDate)
        } else {
            iterEnd = today
        }

        guard today <= iterEnd else { return [] }

        var days: [TimelineDay] = []
        var current = today

        while current <= iterEnd {
            let currentStr = lessonDateFormatter.string(from: current)
            let dayLessons = schedule.exams
                .filter { $0.dateLesson == currentStr && shouldInclude(lesson: $0) }
                .sorted { $0.startTime < $1.startTime }

            if !dayLessons.isEmpty {
                days.append(TimelineDay(date: current, lessons: dayLessons, cycleWeek: nil))
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
// swiftlint:enable type_body_length
// swiftlint:enable file_length
