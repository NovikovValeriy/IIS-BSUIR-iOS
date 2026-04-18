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

    var body: some View {
        if viewModel.timelineDays.isEmpty {
            ContentUnavailableView(
                "schedule.no_classes.title",
                systemImage: Constants.Icons.noClasses,
                description: Text("schedule.no_classes.description \(viewModel.selectedSubject?.displayName ?? "")")
            )
        } else {
            List {
                ForEach(viewModel.timelineDays) { day in
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
