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
    // Indexed by Calendar.weekday (1 = Sunday … 7 = Saturday)
    static let russianWeekdays = [
        "Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"
    ]
}

struct TimelineScheduleView<EmptyState: View>: View {
    var viewModel: ScheduleViewModel
    var days: [TimelineDay]
    var isExhausted: Bool
    var onLoadMore: (() -> Void)?
    var onRefresh: (() async -> Void)?
    @ViewBuilder var emptyState: () -> EmptyState

    var body: some View {
        if days.isEmpty {
            emptyState()
        } else {
            List {
                ForEach(days) { day in
                    Section(viewModel.sectionTitle(for: day)) {
                        ForEach(day.lessons, id: \.self) { lesson in
                            Button {
                                let weekdayIndex = Calendar.current.component(.weekday, from: day.date) - 1
                                let weekday = Constants.russianWeekdays[weekdayIndex]
                                viewModel.didTapLesson(lesson, weekday: weekday)
                            } label: {
                                LessonRowView(lesson: lesson, showWeeks: false, showGroups: viewModel.showGroupsInRow)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(Constants.Layout.rowInsets)
                        }
                    }
                }

                if !isExhausted, let onLoadMore {
                    Color.clear
                        .frame(height: Constants.Layout.sentinelHeight)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .onAppear { onLoadMore() }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .refreshable {
                await onRefresh?()
            }
        }
    }
}
