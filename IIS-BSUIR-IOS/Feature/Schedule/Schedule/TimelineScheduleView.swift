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
}

struct TimelineScheduleView<EmptyState: View>: View {
    var viewModel: ScheduleViewModel
    var days: [TimelineDay]
    var isExhausted: Bool = true
    var onLoadMore: (() -> Void)? = nil
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
                                viewModel.didTapLesson(lesson)
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
        }
    }
}
