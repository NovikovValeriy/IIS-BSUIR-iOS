//
//  ScheduleFlowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct ScheduleFlowView: View {
    @State private var router: ScheduleRouter = Container.shared.scheduleRouter()
    @State private var viewModel: SearchScheduleViewModel = Container.shared.scheduleViewModel()

    var body: some View {
        NavigationStack(path: $router.path) {
            SearchScheduleView(viewModel: viewModel)
                .navigationDestination(for: ScheduleDestination.self) { destination in
                    switch destination {
                    case .lessonDetail(let lesson):
                        LessonDetailView(lesson: lesson)
                    case .employeeSchedule(let employeeId):
                        Text("schedule.employee_schedule.detail \(employeeId)")
                            .navigationTitle("schedule.employee_schedule.title")
                    case .groupSchedule(let groupId):
                        Text("schedule.group_schedule.detail \(groupId)")
                            .navigationTitle("schedule.group_schedule.title")
                    }
                }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            switch sheet {
            case .groupPicker:
                ScheduleSubjectPickerView(
                    groups: viewModel.groups,
                    isLoadingGroups: viewModel.isLoadingGroups,
                    teachers: viewModel.teachers,
                    isLoadingTeachers: viewModel.isLoadingTeachers,
                    onSelect: viewModel.didSelectSubject,
                    onTeacherTabAppear: viewModel.ensureTeachersLoaded
                )
            case .filterOptions:
                Text("schedule.filter.coming_soon")
                    .presentationDetents([.medium])
            case .weekPicker:
                Text("schedule.week_picker.coming_soon")
                    .presentationDetents([.height(300)])
            }
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("common.ok"))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .popToRoot(for: .schedule))) { _ in
            router.popToRoot()
        }
    }
}
