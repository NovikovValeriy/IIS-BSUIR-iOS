//
//  PinnedScheduleViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 17.04.26.
//

import Foundation

@MainActor
final class PinnedScheduleViewModel: ScheduleViewModel {
    private let pinnedScheduleService: any PinnedScheduleServiceProtocol

    init(
        router: ScheduleRouter,
        scheduleService: any ScheduleServiceProtocol,
        pinnedScheduleService: any PinnedScheduleServiceProtocol,
        storage: any StorageProtocol
    ) {
        self.pinnedScheduleService = pinnedScheduleService
        super.init(router: router, scheduleService: scheduleService, storage: storage)
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

    /// Called by `PinnedScheduleFlowView` when the pinned service subject changes.
    func pinnedSubjectDidChange(to subject: ScheduleSubject?) {
        guard subject != selectedSubject else { return }
        if let subject {
            beginLoadingSubject(subject)
        } else {
            unloadSubject()
        }
        router.popToRoot()
    }
}
