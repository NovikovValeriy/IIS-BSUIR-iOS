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
                Spacer()
            }

            HStack(spacing: 16) {
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

private extension ScheduleEmployeeDTO {
    var shortName: String {
        let firstInitial = firstName.first.map { "\($0)." } ?? ""
        let middleInitial = middleName?.first.map { "\($0)." } ?? ""
        return "\(lastName) \(firstInitial)\(middleInitial)"
    }
}
