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
        static let contentSpacing: CGFloat = 4
        static let subjectTitleSpacing: CGFloat = 2
        static let photoSize: CGFloat = 50
        static let groupsColumnWidth: CGFloat = 50
        static let groupsColumnSpacing: CGFloat = 3
        static let groupsMaxVisible: Int = 4
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
        static let timeColumnWidth: CGFloat = 50
        static let timeColumnSpacing: CGFloat = 4
        static let stripeWidth: CGFloat = 8
        static let notePaddingVertical: CGFloat = 8
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let noteBackground = Color(.tertiarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
    }
    enum Icons {
        static let weekNumber = "calendar"
        static let subgroup = "person"
        static let teacherPhotoPlaceholder = "person.circle.fill"
    }
}

struct LessonRowView: View {
    let lesson: Lesson
    var showWeeks: Bool = true
    var showGroups: Bool = false

    var body: some View {
        VStack(spacing: -Constants.Layout.cardCornerRadius) {
            mainCard
                .zIndex(1)
            if let note = lesson.note, !note.isEmpty {
                noteCard(note)
                    .zIndex(0)
            }
        }
    }

    private var mainCard: some View {
        HStack(alignment: .center, spacing: 0) {
            LessonTypeColors.color(forType: lesson.lessonTypeAbbrev, isAnnouncement: lesson.announcement)
                .frame(width: Constants.Layout.stripeWidth)

            HStack(alignment: .center, spacing: Constants.Layout.outerSpacing) {
                timeColumn

                VStack(alignment: .leading, spacing: Constants.Layout.contentSpacing) {
                    HStack(alignment: .center, spacing: Constants.Layout.subjectTitleSpacing) {
                        Text(
                            lesson.announcement
                            ? "lesson.row.announcement".localized()
                            : (lesson.subject ?? "—")
                        )
                        .font(.headline)
                        if showWeeks, let weeks = lesson.weekNumber, !weeks.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: Constants.Icons.weekNumber)
                                Text(weeks.weekDisplayString())
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        if lesson.numSubgroup != 0 {
                            HStack(spacing: 2) {
                                Image(systemName: Constants.Icons.subgroup)
                                Text("\(lesson.numSubgroup)")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    if let room = lesson.auditories.first {
                        Text(room)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if !showGroups, let teacher = lesson.teachers.first {
                        Text(teacher.shortName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if showGroups {
                    groupsColumn
                } else if let teacher = lesson.teachers.first {
                    teacherPhoto(for: teacher)
                }
            }
            .padding(Constants.Layout.cardPadding)
        }
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .shadow(
            color: Constants.Colors.shadowColor,
            radius: Constants.Layout.shadowRadius,
            x: 0,
            y: Constants.Layout.shadowOffsetY
        )
    }

    private func noteCard(_ note: String) -> some View {
        Text(note)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Constants.Layout.cardPadding)
            .padding(.top, Constants.Layout.cardCornerRadius + Constants.Layout.notePaddingVertical)
            .padding(.bottom, Constants.Layout.notePaddingVertical)
            .background(Constants.Colors.noteBackground)
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: Constants.Layout.cardCornerRadius,
                bottomTrailingRadius: Constants.Layout.cardCornerRadius,
                topTrailingRadius: 0
            ))
    }

    private var timeColumn: some View {
        VStack(alignment: .center, spacing: Constants.Layout.timeColumnSpacing) {
            Text(lesson.startTime)
                .font(.headline)
//                .fontWeight(.medium)
                .foregroundStyle(.primary)
            Text(lesson.endTime)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(width: Constants.Layout.timeColumnWidth, alignment: .center)
    }

    @ViewBuilder
    private var groupsColumn: some View {
        let max = Constants.Layout.groupsMaxVisible
        let groups = lesson.groups
        let showEllipsis = groups.count > max
        let visible = showEllipsis ? Array(groups.prefix(max - 1)) : groups

        VStack(alignment: .center, spacing: Constants.Layout.groupsColumnSpacing) {
            ForEach(visible, id: \.name) { group in
                Text(group.name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            if showEllipsis {
                Text("…")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: Constants.Layout.groupsColumnWidth, alignment: .center)
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
    func weekDisplayString() -> String {
        let sorted = self.sorted()
        if sorted == [1, 2, 3, 4] { return "1-4" }
        return sorted.map { "\($0)" }.joined(separator: ", ")
    }
}
