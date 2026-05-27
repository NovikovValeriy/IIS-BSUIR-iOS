//
//  WidgetViews.swift
//  IIS-BSUIR-IOSWidget
//
//  Created by Valery Novikau on 27.05.26.
//

import SwiftUI
import WidgetKit

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

// MARK: - Shared subviews

private struct LessonRowView: View {
    let lesson: WidgetLesson
    let compact: Bool

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(lessonTypeColor(lesson.lessonType))
                .frame(width: 3)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 1) {
                Text(lesson.subject)
                    .font(compact ? .caption2 : .caption)
                    .fontWeight(.medium)
                    .lineLimit(compact ? 1 : 2)

                HStack(spacing: 4) {
                    Text(lesson.startTime)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if let room = lesson.room {
                        Text("·")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(room)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}

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

                    Spacer(minLength: 4)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(lesson.subject)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(2)

                        if let type = lesson.lessonType {
                            Text(type)
                                .font(.caption2)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(lessonTypeColor(lesson.lessonType).opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    Spacer(minLength: 4)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(lesson.startTime)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        if let room = lesson.room {
                            Text("·")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(room)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
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
                    EmptyStateView()
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    let visible = Array(entry.upcomingLessons.prefix(2))
                    ForEach(visible) { lesson in
                        Link(destination: lesson.deepLinkURL ?? URL(string: "iisbsuir://")!) {
                            LessonRowView(lesson: lesson, compact: false)
                                .padding(8)
                                .background(Color(.systemBackground).opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    if entry.upcomingLessons.count > 2 {
                        Text("+ \(entry.upcomingLessons.count - 2)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
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
                    EmptyStateView()
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ForEach(entry.upcomingLessons) { lesson in
                        Link(destination: lesson.deepLinkURL ?? URL(string: "iisbsuir://")!) {
                            LessonRowView(lesson: lesson, compact: false)
                                .padding(10)
                                .background(Color(.systemBackground).opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
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
