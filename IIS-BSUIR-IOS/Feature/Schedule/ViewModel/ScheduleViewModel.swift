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

    init(router: ScheduleRouter) {
        self.router = router
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
}
