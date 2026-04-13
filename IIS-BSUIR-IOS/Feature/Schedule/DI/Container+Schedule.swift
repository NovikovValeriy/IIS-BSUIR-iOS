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

    var scheduleRouter: Factory<ScheduleRouter> {
        self { @MainActor in ScheduleRouter() }.shared
    }

    var scheduleViewModel: Factory<ScheduleViewModel> {
        self { @MainActor in
            ScheduleViewModel(
                router: self.scheduleRouter(),
                scheduleService: self.scheduleService()
            )
        }
    }
}
