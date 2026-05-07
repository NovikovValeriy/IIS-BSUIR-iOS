//
//  SearchScheduleViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 17.04.26.
//

import Foundation

@Observable
@MainActor
final class SearchScheduleViewModel: ScheduleViewModel {
    private let pinnedScheduleService: any PinnedScheduleServiceProtocol

    var groups: [GroupModel] = []
    var teachers: [Teacher] = []
    var isLoadingGroups = false
    var isLoadingTeachers = false

    override var canChangeSubject: Bool { true }

    var isPinned: Bool {
        guard let subject = selectedSubject else { return false }
        return pinnedScheduleService.subject == subject
    }

    init(
        router: ScheduleRouter,
        scheduleService: any ScheduleServiceProtocol,
        pinnedScheduleService: any PinnedScheduleServiceProtocol,
        cacheService: (any ScheduleCacheServiceProtocol)? = nil
    ) {
        self.pinnedScheduleService = pinnedScheduleService
        super.init(router: router, scheduleService: scheduleService, cacheService: cacheService)
    }

    // MARK: - Lifecycle

    override func onAppear() {
        super.onAppear()
        guard groups.isEmpty, !isLoadingGroups else { return }
        isLoadingGroups = true
        Task { await loadGroups() }
    }

    override var navigationTitle: String {
        selectedSubject?.displayName ?? String(localized: "schedule.search.title")
    }

    // MARK: - Actions

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
        router.dismissSheet()
        beginLoadingSubject(subject, resetFilter: true)
    }

    func didTapPin() {
        guard let subject = selectedSubject else { return }
        if pinnedScheduleService.subject == subject {
            pinnedScheduleService.clear()
        } else {
            pinnedScheduleService.save(subject)
        }
    }

    // MARK: - Private

    private func loadGroups() async {
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
}
