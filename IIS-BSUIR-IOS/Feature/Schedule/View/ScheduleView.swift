//
//  ScheduleView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct ScheduleView: View {
    @State private var viewModel: ScheduleViewModel = Container.shared.scheduleViewModel()

    var body: some View {
        Group {
            if viewModel.lessons.isEmpty {
                ContentUnavailableView(
                    "No Classes",
                    systemImage: "calendar",
                    description: Text("No schedule available for this week.")
                )
            } else {
                List {
                    ForEach(viewModel.weekdayOrder, id: \.self) { weekday in
                        if let dayLessons = viewModel.lessons[weekday] {
                            Section(weekday) {
                                ForEach(dayLessons, id: \.self) { lesson in
                                    Button {
                                        viewModel.didTapLesson(lesson)
                                    } label: {
                                        LessonRowView(lesson: lesson)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Schedule")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.didTapWeekPicker) {
                    Image(systemName: "calendar.badge.clock")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.didTapFilter) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
}
