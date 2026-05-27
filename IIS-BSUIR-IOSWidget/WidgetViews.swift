//
//  WidgetViews.swift
//  IIS-BSUIR-IOSWidget
//
//  Created by Valery Novikau on 27.05.26.
//

import SwiftUI
import WidgetKit

// MARK: - Constants

private enum Constants {
    enum Layout {
        static let stripeWidth: CGFloat = 6
        static let outerSpacing: CGFloat = 10
        static let contentSpacing: CGFloat = 3
        static let timeColumnWidth: CGFloat = 44
        static let timeColumnSpacing: CGFloat = 3
        static let cardPadding: CGFloat = 10
        static let cardCornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
    }
}

// MARK: - Lesson type color

private func lessonTypeColor(_ type: String?) -> Color {
    switch type {
    case "ЛК": return .green
    case "ПЗ": return .yellow
    case "ЛР": return .red
    case "Экзамен": return .purple
    case "Консультация": return .brown
    default: return .gray
    }
}

// MARK: - Lesson card

private struct LessonCardView: View {
    let lesson: WidgetLesson

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            lessonTypeColor(lesson.lessonType)
                .frame(width: Constants.Layout.stripeWidth)

            HStack(alignment: .center, spacing: Constants.Layout.outerSpacing) {
                timeColumn
                contentColumn
            }
            .padding(Constants.Layout.cardPadding)
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .shadow(
            color: Constants.Colors.shadowColor,
            radius: Constants.Layout.shadowRadius,
            x: 0,
            y: Constants.Layout.shadowOffsetY
        )
    }

    private var timeColumn: some View {
        VStack(alignment: .center, spacing: Constants.Layout.timeColumnSpacing) {
            Text(lesson.startTime)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            Text(lesson.endTime)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: Constants.Layout.timeColumnWidth, alignment: .center)
    }

    private var contentColumn: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.contentSpacing) {
            Text(lesson.subject)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            let meta = [lesson.room, lesson.teacherName].compactMap { $0 }.joined(separator: " · ")
            if !meta.isEmpty {
                Text(meta)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Empty / no-schedule states

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(String(localized: "widget.no_lessons"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

private struct NoScheduleView: View {
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(String(localized: "widget.no_schedule"))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Small

struct WidgetSmallView: View {
    let entry: ScheduleEntry

    var body: some View {
        if entry.subjectName.isEmpty {
            NoScheduleView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let lesson = entry.upcomingLessons.first {
            Link(destination: lesson.deepLinkURL ?? URL(string: "iisbsuir://")!) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(entry.subjectName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Spacer(minLength: 6)

                    VStack(alignment: .leading, spacing: Constants.Layout.contentSpacing) {
                        Text(lesson.subject)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(2)

                        if let room = lesson.room {
                            Text(room)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        if let teacher = lesson.teacherName {
                            Text(teacher)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer(minLength: 6)

                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(lessonTypeColor(lesson.lessonType))
                            .frame(width: 3, height: 12)
                        Text("\(lesson.startTime) – \(lesson.endTime)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        } else {
            EmptyStateView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Medium

struct WidgetMediumView: View {
    let entry: ScheduleEntry

    var body: some View {
        if entry.subjectName.isEmpty {
            NoScheduleView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.subjectName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(localized: "widget.today"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if entry.upcomingLessons.isEmpty {
                    Spacer()
                    EmptyStateView().frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ForEach(entry.upcomingLessons.prefix(2)) { lesson in
                        Link(destination: lesson.deepLinkURL ?? URL(string: "iisbsuir://")!) {
                            LessonCardView(lesson: lesson)
                        }
                    }
                    if entry.upcomingLessons.count > 2 {
                        Text(String(localized: "+ \(entry.upcomingLessons.count - 2)"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

// MARK: - Large

struct WidgetLargeView: View {
    let entry: ScheduleEntry

    var body: some View {
        if entry.subjectName.isEmpty {
            NoScheduleView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(entry.subjectName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(localized: "widget.today"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if entry.upcomingLessons.isEmpty {
                    Spacer()
                    EmptyStateView().frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ForEach(entry.upcomingLessons) { lesson in
                        Link(destination: lesson.deepLinkURL ?? URL(string: "iisbsuir://")!) {
                            LessonCardView(lesson: lesson)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
