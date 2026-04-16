//
//  TimelineScheduleView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 14.04.26.
//

import SwiftUI

private enum Constants {
    enum Layout {
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        static let sentinelHeight: CGFloat = 1
    }
    enum Icons {
        static let noClasses = "calendar"
    }
}

struct TimelineScheduleView: View {
    var viewModel: ScheduleViewModel

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private static let dayMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }()

    private static let dayMonthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    private func sectionTitle(for day: TimelineDay) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayStart = calendar.startOfDay(for: day.date)

        var parts: [String] = []

        if dayStart == today {
            parts.append(String(localized: "schedule.timeline.today"))
        } else if dayStart == calendar.date(byAdding: .day, value: 1, to: today) {
            parts.append(String(localized: "schedule.timeline.tomorrow"))
        }

        parts.append(Self.weekdayFormatter.string(from: day.date))

        let sameYear = calendar.isDate(day.date, equalTo: Date(), toGranularity: .year)
        parts.append(sameYear
            ? Self.dayMonthFormatter.string(from: day.date)
            : Self.dayMonthYearFormatter.string(from: day.date))

        if let week = day.cycleWeek {
            parts.append(String(localized: "schedule.timeline.week \(week)"))
        }

        return parts.joined(separator: ", ")
    }

    var body: some View {
        if viewModel.timelineDays.isEmpty {
            ContentUnavailableView(
                "schedule.no_classes.title",
                systemImage: Constants.Icons.noClasses,
                description: Text("schedule.no_classes.description \(viewModel.selectedGroup?.name ?? "")")
            )
        } else {
            List {
                ForEach(viewModel.timelineDays) { day in
                    Section(sectionTitle(for: day)) {
                        ForEach(day.lessons, id: \.self) { lesson in
                            Button {
                                viewModel.didTapLesson(lesson)
                            } label: {
                                LessonRowView(lesson: lesson, showWeeks: false)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(Constants.Layout.rowInsets)
                        }
                    }
                }

                if !viewModel.timelineExhausted {
                    Color.clear
                        .frame(height: Constants.Layout.sentinelHeight)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .onAppear {
                            viewModel.loadMoreTimelineDays()
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
        }
    }
}
