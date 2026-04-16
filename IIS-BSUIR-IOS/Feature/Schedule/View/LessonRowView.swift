//
//  LessonRowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 13.04.26.
//

import Kingfisher
import SwiftUI

private enum Constants {
    enum Layout {
        static let outerSpacing: CGFloat = 12
        static let contentSpacing: CGFloat = 6
        static let badgePaddingHorizontal: CGFloat = 6
        static let badgePaddingVertical: CGFloat = 2
        static let badgeCornerRadius: CGFloat = 4
        static let photoSize: CGFloat = 50
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
    }
    enum Colors {
        static let badgeBackgroundOpacity: Double = 0.15
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
    }
    enum Icons {
        static let weekNumber = "number"
        static let time = "clock"
        static let room = "mappin"
        static let teacher = "person"
        static let group = "person.3"
        static let teacherPhotoPlaceholder = "person.circle.fill"
    }
}

struct LessonRowView: View {
    let lesson: Lesson
    var showWeeks: Bool = true
    var showGroups: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: Constants.Layout.outerSpacing) {
            VStack(alignment: .leading, spacing: Constants.Layout.contentSpacing) {
                HStack(alignment: .firstTextBaseline) {
                    Text(lesson.subject ?? "—")
                        .font(.headline)
                    if let type = lesson.lessonTypeAbbrev {
                        Text(type)
                            .font(.caption)
                            .padding(.horizontal, Constants.Layout.badgePaddingHorizontal)
                            .padding(.vertical, Constants.Layout.badgePaddingVertical)
                            .background(Color.accentColor.opacity(Constants.Colors.badgeBackgroundOpacity))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.badgeCornerRadius))
                    }
                    if lesson.numSubgroup != 0 {
                        Text("lesson.row.subgroup \(lesson.numSubgroup)")
                            .font(.caption)
                            .padding(.horizontal, Constants.Layout.badgePaddingHorizontal)
                            .padding(.vertical, Constants.Layout.badgePaddingVertical)
                            .background(Color.secondary.opacity(Constants.Colors.badgeBackgroundOpacity))
                            .foregroundStyle(.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.badgeCornerRadius))
                    }
                    Spacer()
                }

                if showWeeks, let weeks = lesson.weekNumber, !weeks.isEmpty {
                    Label(
                        "lesson.row.weeks \(weeks.formattedNumbers())",
                        systemImage: Constants.Icons.weekNumber
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Label(
                    "\(lesson.startTime) – \(lesson.endTime)",
                    systemImage: Constants.Icons.time
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if let room = lesson.auditories.first {
                    Label(room, systemImage: Constants.Icons.room)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if showGroups {
                    if !lesson.groups.isEmpty {
                        let names = lesson.groups.map { $0.name }.joined(separator: ", ")
                        Label(names, systemImage: Constants.Icons.group)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else if let teacher = lesson.teachers.first {
                    Label(teacher.shortName, systemImage: Constants.Icons.teacher)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if !showGroups, let teacher = lesson.teachers.first {
                teacherPhoto(for: teacher)
            }
        }
        .padding(Constants.Layout.cardPadding)
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .shadow(
            color: Constants.Colors.shadowColor,
            radius: Constants.Layout.shadowRadius,
            x: 0,
            y: Constants.Layout.shadowOffsetY
        )
    }

    @ViewBuilder
    private func teacherPhoto(for teacher: Teacher) -> some View {
        let size = Constants.Layout.photoSize
        if let urlString = teacher.photoLink, let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .placeholder {
                    Image(systemName: Constants.Icons.teacherPhotoPlaceholder)
                        .resizable()
                        .foregroundStyle(Color.secondary)
                }
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            Image(systemName: Constants.Icons.teacherPhotoPlaceholder)
                .resizable()
                .foregroundStyle(Color.secondary)
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }
}

private extension [Int] {
    /// Formats a sorted list of week numbers into a compact string, e.g. [1,2,3,5] → "1–3, 5"
    func formattedNumbers() -> String {
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
        return parts.joined(separator: ", ")
    }
}
