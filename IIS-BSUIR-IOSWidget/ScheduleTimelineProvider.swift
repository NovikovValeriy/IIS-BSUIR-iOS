//
//  ScheduleTimelineProvider.swift
//  IIS-BSUIR-IOSWidget
//
//  Created by Valery Novikau on 27.05.26.
//

import WidgetKit

struct ScheduleTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> ScheduleEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
        } else {
            completion(currentEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> Void) {
        let entries = buildEntries()
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        )
        completion(Timeline(entries: entries, policy: .after(midnight)))
    }

    // MARK: - Private

    private func currentEntry() -> ScheduleEntry {
        guard let snapshot = WidgetDataStore.load(), !snapshot.lessonsToday.isEmpty else {
            return .empty
        }
        let upcoming = upcomingLessons(from: snapshot.lessonsToday)
        return ScheduleEntry(date: .now, subjectName: snapshot.subjectName, upcomingLessons: upcoming)
    }

    private func buildEntries() -> [ScheduleEntry] {
        guard let snapshot = WidgetDataStore.load() else {
            return [ScheduleEntry(date: .now, subjectName: "", upcomingLessons: [])]
        }

        let lessons = snapshot.lessonsToday
        let now = Date()
        var entries: [ScheduleEntry] = []

        let initialUpcoming = upcomingLessons(from: lessons)
        entries.append(ScheduleEntry(date: now, subjectName: snapshot.subjectName, upcomingLessons: initialUpcoming))

        for (index, lesson) in lessons.enumerated() where lesson.startDate > now {
            let upcoming = Array(lessons[index...])
            entries.append(ScheduleEntry(
                date: lesson.startDate,
                subjectName: snapshot.subjectName,
                upcomingLessons: upcoming
            ))
        }

        if let lastLesson = lessons.last {
            let endDate = Calendar.current.date(
                byAdding: .minute,
                value: 95,
                to: lastLesson.startDate
            ) ?? lastLesson.startDate
            entries.append(ScheduleEntry(date: endDate, subjectName: snapshot.subjectName, upcomingLessons: []))
        }

        return entries
    }

    private func upcomingLessons(from lessons: [WidgetLesson]) -> [WidgetLesson] {
        let now = Date()
        let cutoff = Calendar.current.date(byAdding: .minute, value: -95, to: now) ?? now
        if let firstVisible = lessons.first(where: { $0.startDate >= cutoff }) {
            return lessons.filter { $0.startDate >= firstVisible.startDate }
        }
        return []
    }
}
