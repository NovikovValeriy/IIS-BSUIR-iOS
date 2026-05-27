//
//  ScheduleEntry.swift
//  IIS-BSUIR-IOSWidget
//
//  Created by Valery Novikau on 27.05.26.
//

import WidgetKit

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let subjectName: String
    let upcomingLessons: [WidgetLesson]

    static let placeholder = ScheduleEntry(
        date: .now,
        subjectName: "250502",
        upcomingLessons: [
            WidgetLesson(
                id: "placeholder_1",
                subject: "Математический анализ",
                lessonType: "ЛК",
                startTime: "09:00",
                endTime: "10:35",
                room: "309-1",
                teacherName: "Иванов И.И.",
                weekday: "Понедельник",
                startDate: .now
            ),
            WidgetLesson(
                id: "placeholder_2",
                subject: "Алгоритмы",
                lessonType: "ЛР",
                startTime: "11:00",
                endTime: "12:35",
                room: "204-2",
                teacherName: "Петров П.П.",
                weekday: "Понедельник",
                startDate: Calendar.current.date(byAdding: .hour, value: 2, to: .now) ?? .now
            )
        ]
    )

    static let empty = ScheduleEntry(date: .now, subjectName: "", upcomingLessons: [])
}
