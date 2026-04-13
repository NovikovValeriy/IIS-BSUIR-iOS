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
                ProgressView("Loading schedule…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.selectedGroup == nil {
                noGroupView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else if viewModel.lessons.isEmpty {
                ContentUnavailableView(
                    "No Classes",
                    systemImage: "calendar",
                    description: Text("No schedule found for \(viewModel.selectedGroup?.name ?? "").")
                )
            } else {
                scheduleList
            }
        }
        .navigationTitle(viewModel.selectedGroup.map { "Group \($0.name)" } ?? "Schedule")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.didTapSelectGroup()
                } label: {
                    Label("Group", systemImage: "person.3")
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var noGroupView: some View {
        ContentUnavailableView {
            Label("No Group Selected", systemImage: "person.3")
        } description: {
            Text("Select your group to view the schedule.")
        } actions: {
            Button("Select Group") {
                viewModel.didTapSelectGroup()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Something Went Wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry") {
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
