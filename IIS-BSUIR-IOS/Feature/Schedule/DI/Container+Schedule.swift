//
//  Container+Schedule.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Factory

extension Container {
    var scheduleService: Factory<any ScheduleServiceProtocol> {
        self { @MainActor in ScheduleService(apiClient: self.apiClient()) }.shared
    }

    var pinnedScheduleService: Factory<PinnedScheduleService> {
        self { @MainActor in PinnedScheduleService(storage: self.storage()) }.shared
    }

    // MARK: - Search schedule (second tab)

    var scheduleRouter: Factory<ScheduleRouter> {
        self { @MainActor in ScheduleRouter() }.shared
    }

    var scheduleViewModel: Factory<SearchScheduleViewModel> {
        self { @MainActor in
            SearchScheduleViewModel(
                router: self.scheduleRouter(),
                scheduleService: self.scheduleService(),
                pinnedScheduleService: self.pinnedScheduleService()
            )
        }
    }

    // MARK: - Pinned schedule (first tab)

    var pinnedScheduleRouter: Factory<ScheduleRouter> {
        self { @MainActor in ScheduleRouter() }.shared
    }

    var pinnedScheduleViewModel: Factory<PinnedScheduleViewModel> {
        self { @MainActor in
            PinnedScheduleViewModel(
                router: self.pinnedScheduleRouter(),
                scheduleService: self.scheduleService(),
                pinnedScheduleService: self.pinnedScheduleService(),
                storage: self.storage()
            )
        }
    }
}
