//
//  LessonDetailView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI

private enum Constants {
    enum Layout {
        static let itemSpacing: CGFloat = 4
        static let itemPaddingVertical: CGFloat = 2
    }
    enum Icons {
        static let chevron = "chevron.right"
    }
}

struct LessonDetailView: View {
    let lesson: Lesson
    let router: ScheduleRouter

    var body: some View {
        List {
            subjectSection
            timeSection
            if !lesson.auditories.isEmpty {
                roomsSection(lesson.auditories)
            }
            if !lesson.teachers.isEmpty {
                teachersSection(lesson.teachers)
            }
            if !lesson.groups.isEmpty {
                groupsSection(lesson.groups)
            }
            if let weeks = lesson.weekNumber, !weeks.isEmpty {
                weeksSection(weeks)
            }
            if let note = lesson.note, !note.isEmpty {
                noteSection(note)
            }
        }
        .navigationTitle(lesson.subjectFullName ?? lesson.subject ?? String(localized: "lesson.detail.default_title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var subjectSection: some View {
        Section {
            LabeledContent("lesson.detail.subject", value: lesson.subjectFullName ?? lesson.subject ?? "—")
            if let type = lesson.lessonTypeAbbrev {
                LabeledContent("lesson.detail.type", value: type)
            }
            if lesson.numSubgroup != 0 {
                LabeledContent("lesson.detail.subgroup", value: "\(lesson.numSubgroup)")
            }
            if lesson.announcement {
                LabeledContent("lesson.detail.kind", value: String(localized: "lesson.detail.announcement"))
            }
        }
    }

    private var timeSection: some View {
        Section("lesson.detail.time") {
            LabeledContent("lesson.detail.start", value: lesson.startTime)
            LabeledContent("lesson.detail.end", value: lesson.endTime)
            if let date = lesson.dateLesson {
                LabeledContent("lesson.detail.date", value: date)
            }
            if let start = lesson.startLessonDate, let end = lesson.endLessonDate {
                LabeledContent("lesson.detail.period", value: "\(start) – \(end)")
            }
        }
    }

    private func roomsSection(_ rooms: [String]) -> some View {
        Section("lesson.detail.classrooms") {
            ForEach(rooms, id: \.self) { room in
                Text(room)
            }
        }
    }

    private func teachersSection(_ teachers: [Teacher]) -> some View {
        Section(teachers.count == 1 ? "lesson.detail.teacher" : "lesson.detail.teachers") {
            ForEach(teachers) { teacher in
                Button {
                    router.push(.employeeSchedule(teacher))
                } label: {
                    teacherRow(teacher)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func teacherRow(_ teacher: Teacher) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.Layout.itemSpacing) {
                Text(teacher.fullName)
                    .font(.body)
                    .foregroundStyle(.primary)
                if let rank = teacher.rank, !rank.isEmpty {
                    Text(rank)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let degree = teacher.degree, !degree.isEmpty {
                    Text(degree)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let email = teacher.email, !email.isEmpty {
                    Text(email)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: Constants.Icons.chevron)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .padding(.vertical, Constants.Layout.itemPaddingVertical)
    }

    private func groupsSection(_ groups: [LessonGroup]) -> some View {
        Section(groups.count == 1 ? "lesson.detail.group" : "lesson.detail.groups") {
            ForEach(groups, id: \.name) { group in
                Button {
                    router.push(.groupSchedule(group.name))
                } label: {
                    groupRow(group)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func groupRow(_ group: LessonGroup) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.Layout.itemSpacing) {
                Text(group.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                if let speciality = group.specialityName, !speciality.isEmpty {
                    Text(speciality)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let count = group.numberOfStudents {
                    Text("lesson.detail.students_count \(count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: Constants.Icons.chevron)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .padding(.vertical, Constants.Layout.itemPaddingVertical)
    }

    private func weeksSection(_ weeks: [Int]) -> some View {
        Section("lesson.detail.weeks") {
            Text(weeks.sorted().map { "\($0)" }.joined(separator: ", "))
                .foregroundStyle(.secondary)
        }
    }

    private func noteSection(_ note: String) -> some View {
        Section("lesson.detail.note") {
            Text(note)
                .foregroundStyle(.secondary)
        }
    }
}
