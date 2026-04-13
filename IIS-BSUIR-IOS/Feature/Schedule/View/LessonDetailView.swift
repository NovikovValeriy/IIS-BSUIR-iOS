//
//  LessonDetailView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI

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
        .navigationTitle(lesson.subjectFullName ?? lesson.subject ?? "Lesson")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var subjectSection: some View {
        Section {
            LabeledContent("Subject", value: lesson.subjectFullName ?? lesson.subject ?? "—")
            if let type = lesson.lessonTypeAbbrev {
                LabeledContent("Type", value: type)
            }
            if lesson.numSubgroup != 0 {
                LabeledContent("Subgroup", value: "\(lesson.numSubgroup)")
            }
            if lesson.announcement {
                LabeledContent("Kind", value: "Announcement")
            }
        }
    }

    private var timeSection: some View {
        Section("Time") {
            LabeledContent("Start", value: lesson.startLessonTime)
            LabeledContent("End", value: lesson.endLessonTime)
            if let date = lesson.dateLesson {
                LabeledContent("Date", value: date)
            }
            if let start = lesson.startLessonDate, let end = lesson.endLessonDate {
                LabeledContent("Period", value: "\(start) – \(end)")
            }
        }
    }

    private func roomsSection(_ rooms: [String]) -> some View {
        Section("Classrooms") {
            ForEach(rooms, id: \.self) { room in
                Text(room)
            }
        }
    }

    private func teachersSection(_ employees: [ScheduleEmployeeDTO]) -> some View {
        Section(employees.count == 1 ? "Teacher" : "Teachers") {
            ForEach(employees, id: \.id) { employee in
                VStack(alignment: .leading, spacing: 4) {
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
                .padding(.vertical, 2)
            }
        }
    }

    private func groupsSection(_ groups: [LessonStudentGroupDTO]) -> some View {
        Section(groups.count == 1 ? "Group" : "Groups") {
            ForEach(groups, id: \.name) { group in
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.body)
                    if let speciality = group.specialityName {
                        Text(speciality)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let count = group.numberOfStudents {
                        Text("\(count) students")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func weeksSection(_ weeks: [Int]) -> some View {
        Section("Weeks") {
            Text(weeks.sorted().map { "\($0)" }.joined(separator: ", "))
                .foregroundStyle(.secondary)
        }
    }

    private func noteSection(_ note: String) -> some View {
        Section("Note") {
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
