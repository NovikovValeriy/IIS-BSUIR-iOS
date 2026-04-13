//
//  ScheduleView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI

struct ScheduleView: View {
    var viewModel: ScheduleViewModel

    var body: some View {
        Group {
            if viewModel.isLoadingSchedule {
                ProgressView("schedule.loading")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.selectedGroup == nil {
                noGroupView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else if viewModel.lessons.isEmpty {
                ContentUnavailableView(
                    "schedule.no_classes.title",
                    systemImage: "calendar",
                    description: Text("schedule.no_classes.description \(viewModel.selectedGroup?.name ?? "")")
                )
            } else {
                scheduleList
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.didTapSelectGroup()
                } label: {
                    Label("schedule.select_group.label", systemImage: "person.3")
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var noGroupView: some View {
        ContentUnavailableView {
            Label("schedule.no_group.title", systemImage: "person.3")
        } description: {
            Text("schedule.no_group.description")
        } actions: {
            Button("schedule.select_group.action") {
                viewModel.didTapSelectGroup()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("common.error.title", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("schedule.retry") {
                viewModel.didTapSelectGroup()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var scheduleList: some View {
        List {
            ForEach(viewModel.weekdayOrder, id: \.self) { weekday in
                if let dayLessons = viewModel.lessons[weekday] {
                    Section(weekday) {
                        ForEach(dayLessons, id: \.self) { lesson in
                            Button {
                                viewModel.didTapLesson(lesson)
                            } label: {
                                LessonRowView(lesson: lesson)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}
