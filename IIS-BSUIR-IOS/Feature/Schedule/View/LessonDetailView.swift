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
}

struct LessonDetailView: View {
    let lesson: LessonDTO

    var body: some View {
        List {
            subjectSection
            timeSection
            if let rooms = lesson.auditories, !rooms.isEmpty {
                roomsSection(rooms)
            }
            if let employees = lesson.employees, !employees.isEmpty {
                teachersSection(employees)
            }
            if !lesson.studentGroups.isEmpty {
                groupsSection(lesson.studentGroups)
            }
            if let weeks = lesson.weekNumber, !weeks.isEmpty {
                weeksSection(weeks)
            }
            if let note = lesson.note {
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
            LabeledContent("lesson.detail.start", value: lesson.startLessonTime)
            LabeledContent("lesson.detail.end", value: lesson.endLessonTime)
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

    private func teachersSection(_ employees: [ScheduleEmployeeDTO]) -> some View {
        Section(employees.count == 1 ? "lesson.detail.teacher" : "lesson.detail.teachers") {
            ForEach(employees, id: \.id) { employee in
                VStack(alignment: .leading, spacing: Constants.Layout.itemSpacing) {
                    Text(employee.fullName)
                        .font(.body)
                    if let rank = employee.rank {
                        Text(rank)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let degree = employee.degree {
                        Text(degree)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let email = employee.email {
                        Text(email)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, Constants.Layout.itemPaddingVertical)
            }
        }
    }

    private func groupsSection(_ groups: [LessonStudentGroupDTO]) -> some View {
        Section(groups.count == 1 ? "lesson.detail.group" : "lesson.detail.groups") {
            ForEach(groups, id: \.name) { group in
                VStack(alignment: .leading, spacing: Constants.Layout.itemSpacing) {
                    Text(group.name)
                        .font(.body)
                    if let speciality = group.specialityName {
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
                .padding(.vertical, Constants.Layout.itemPaddingVertical)
            }
        }
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

// MARK: - Helpers

private extension ScheduleEmployeeDTO {
    var fullName: String {
        [lastName, firstName, middleName].compactMap { $0 }.joined(separator: " ")
    }
}
