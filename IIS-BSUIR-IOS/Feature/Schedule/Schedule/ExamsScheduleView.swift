//
//  ExamsScheduleView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 18.04.26.
//

import SwiftUI

private enum Constants {
    enum Layout {
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
    }
    enum Icons {
        static let noExams = "graduationcap"
    }
}

struct ExamsScheduleView: View {
    var viewModel: ScheduleViewModel

    var body: some View {
        if viewModel.examsDays.isEmpty {
            ContentUnavailableView(
                "schedule.no_exams.title",
                systemImage: Constants.Icons.noExams,
                description: Text("schedule.no_exams.description \(viewModel.selectedSubject?.displayName ?? "")")
            )
        } else {
            List {
                ForEach(viewModel.examsDays) { day in
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
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
        }
    }
}
