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

    var groups: [StudentGroupDTO] = []
    var selectedGroup: StudentGroupDTO?
    var lessons: [String: [LessonDTO]] = [:]
    var isLoadingGroups = false
    var isLoadingSchedule = false
    var errorMessage: String?

    var navigationTitle: String {
        if let group = selectedGroup {
            return String(localized: "schedule.group_title \(group.name)")
        }
        return String(localized: "schedule.title")
    }

    init(router: ScheduleRouter, scheduleService: any ScheduleServiceProtocol) {
        self.router = router
        self.scheduleService = scheduleService
    }

    func onAppear() {
        Task { await loadGroups() }
    }

    func didTapSelectGroup() {
        router.present(sheet: .groupPicker)
    }

    func didSelectGroup(_ group: StudentGroupDTO) {
        selectedGroup = group
        router.dismissSheet()
        Task { await loadSchedule(for: group) }
    }

    func didTapLesson(_ lesson: LessonDTO) {
        router.push(.lessonDetail(lesson))
    }

    func didTapFilter() {
        router.present(sheet: .filterOptions)
    }

    func didTapWeekPicker() {
        router.present(sheet: .weekPicker)
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

    private func loadSchedule(for group: StudentGroupDTO) async {
        isLoadingSchedule = true
        errorMessage = nil
        do {
            let response = try await scheduleService.fetchGroupSchedule(groupName: group.name)
            lessons = response.schedules ?? [:]
        } catch {
            errorMessage = String(localized: "schedule.error.load_schedule \(group.name)")
            lessons = [:]
        }
        isLoadingSchedule = false
    }
}
