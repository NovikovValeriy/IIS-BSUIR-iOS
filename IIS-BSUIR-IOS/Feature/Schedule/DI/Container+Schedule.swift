//
//  Container+Schedule.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Factory

extension Container {
    var scheduleRouter: Factory<ScheduleRouter> {
        self { @MainActor in ScheduleRouter() }.shared
    }

    var scheduleViewModel: Factory<ScheduleViewModel> {
        self { @MainActor in ScheduleViewModel(router: self.scheduleRouter()) }
    }
}
