//
//  LinkedScheduleViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 18.04.26.
//

import Foundation

@Observable
@MainActor
final class LinkedScheduleViewModel: ScheduleViewModel {
    private let initialSubject: ScheduleSubject

    init(
        subject: ScheduleSubject,
        router: ScheduleRouter,
        scheduleService: any ScheduleServiceProtocol
    ) {
        self.initialSubject = subject
        super.init(router: router, scheduleService: scheduleService)
    }

    override func onAppear() {
        super.onAppear()
        guard selectedSubject == nil else { return }
        beginLoadingSubject(initialSubject)
    }
}
