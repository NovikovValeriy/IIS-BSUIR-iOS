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

    // Ordered Russian weekday names matching the API
    let weekdayOrder = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]

    // TODO: Replace with real data from the schedule service
    var lessons: [String: [LessonDTO]] = mockLessons

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

// MARK: - Mock Data

private extension ScheduleViewModel {
    static let mockEmployee = ScheduleEmployeeDTO(
        id: 500434,
        firstName: "Игорь",
        middleName: "Иванович",
        lastName: "Абрамов",
        photoLink: nil,
        degree: "д.ф.-м.н.",
        degreeAbbrev: "д.ф.-м.н.",
        rank: "профессор",
        email: "abramov@bsuir.by",
        urlId: "i-abramov",
        calendarId: nil,
        jobPositions: nil
    )

    static let mockEmployee2 = ScheduleEmployeeDTO(
        id: 500740,
        firstName: "Елена",
        middleName: "Дмитриевна",
        lastName: "Стройникова",
        photoLink: nil,
        degree: nil,
        degreeAbbrev: nil,
        rank: "доцент",
        email: nil,
        urlId: "e-stroynikova",
        calendarId: nil,
        jobPositions: nil
    )

    static let mockGroup = LessonStudentGroupDTO(
        specialityName: "Информационные системы и технологии",
        specialityCode: "1-40 05 01",
        numberOfStudents: 25,
        name: "253501",
        educationDegree: 1
    )

    static func makeMockLesson(
        subject: String,
        subjectFull: String,
        type: String,
        start: String,
        end: String,
        room: String,
        employee: ScheduleEmployeeDTO,
        weeks: [Int] = [1, 2, 3, 4]
    ) -> LessonDTO {
        LessonDTO(
            auditories: [room],
            endLessonTime: end,
            lessonTypeAbbrev: type,
            note: nil,
            numSubgroup: 0,
            startLessonTime: start,
            studentGroups: [mockGroup],
            subject: subject,
            subjectFullName: subjectFull,
            weekNumber: weeks,
            employees: [employee],
            dateLesson: nil,
            startLessonDate: nil,
            endLessonDate: nil,
            announcement: false,
            split: false
        )
    }

    static let mockLessons: [String: [LessonDTO]] = [
        "Понедельник": [
            makeMockLesson(
                subject: "МатАн",
                subjectFull: "Математический анализ",
                type: "ЛК",
                start: "10:35",
                end: "11:55",
                room: "501-5к",
                employee: mockEmployee
            ),
            makeMockLesson(
                subject: "ОАиП",
                subjectFull: "Основы алгоритмизации и программирования",
                type: "ЛР",
                start: "12:25",
                end: "13:45",
                room: "302-6к",
                employee: mockEmployee2
            )
        ],
        "Вторник": [
            makeMockLesson(
                subject: "Физика",
                subjectFull: "Физика",
                type: "ЛК",
                start: "08:00",
                end: "09:35",
                room: "201-4к",
                employee: mockEmployee
            ),
            makeMockLesson(
                subject: "ОАиП",
                subjectFull: "Основы алгоритмизации и программирования",
                type: "ПЗ",
                start: "10:35",
                end: "11:55",
                room: "302-6к",
                employee: mockEmployee2
            )
        ],
        "Среда": [
            makeMockLesson(
                subject: "МатАн",
                subjectFull: "Математический анализ",
                type: "ПЗ",
                start: "12:25",
                end: "13:45",
                room: "415-5к",
                employee: mockEmployee,
                weeks: [1, 3]
            ),
            makeMockLesson(
                subject: "Физика",
                subjectFull: "Физика",
                type: "ЛР",
                start: "14:15",
                end: "15:35",
                room: "103-4к",
                employee: mockEmployee2,
                weeks: [2, 4]
            )
        ],
        "Пятница": [
            makeMockLesson(
                subject: "ОАиП",
                subjectFull: "Основы алгоритмизации и программирования",
                type: "ЛК",
                start: "08:00",
                end: "09:35",
                room: "207-1к",
                employee: mockEmployee2
            )
        ]
    ]
}
