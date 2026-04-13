//
//  LessonRowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 13.04.26.
//

import SwiftUI

struct LessonRowView: View {
    let lesson: LessonDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(lesson.subject ?? "—")
                    .font(.headline)
                if let type = lesson.lessonTypeAbbrev {
                    Text(type)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                if lesson.numSubgroup != 0 {
                    Text("Subgroup \(lesson.numSubgroup)")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .foregroundStyle(.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                Spacer()
            }

            if let weeks = lesson.weekNumber, !weeks.isEmpty {
                Label(weeks.formatted(), systemImage: "number")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Label(
                "\(lesson.startLessonTime) – \(lesson.endLessonTime)",
                systemImage: "clock"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if let room = lesson.auditories?.first {
                Label(room, systemImage: "mappin")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let teacher = lesson.employees?.first {
                Label(teacher.shortName, systemImage: "person")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

private extension [Int] {
    /// Formats a sorted list of week numbers into a compact string, e.g. [1,2,3,5] → "Weeks 1–3, 5"
    func formatted() -> String {
        guard !isEmpty else { return "" }
        let sorted = self.sorted()
        var ranges: [(Int, Int)] = []
        var start = sorted[0], end = sorted[0]
        for week in sorted.dropFirst() {
            if week == end + 1 {
                end = week
            } else {
                ranges.append((start, end))
                start = week; end = week
            }
        }
        ranges.append((start, end))
        let parts = ranges.map { start, end in start == end ? "\(start)" : "\(start)–\(end)" }
        return "Weeks \(parts.joined(separator: ", "))"
    }
}

private extension ScheduleEmployeeDTO {
    var shortName: String {
        let firstInitial = firstName.first.map { "\($0)." } ?? ""
        let middleInitial = middleName?.first.map { "\($0)." } ?? ""
        return "\(lastName) \(firstInitial)\(middleInitial)"
    }
}
