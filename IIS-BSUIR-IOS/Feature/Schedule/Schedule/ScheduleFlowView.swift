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
                    case .lessonDetail(let lesson, let weekday):
                        LessonDetailView(lesson: lesson, weekday: weekday, router: router)
                    case .employeeSchedule(let teacher):
                        LinkedScheduleView(subject: .teacher(teacher), router: router)
                    case .groupSchedule(let groupName):
                        LinkedScheduleView(subject: .group(.minimal(name: groupName)), router: router)
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
            }
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("common.ok".localized()))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .popToRoot(for: .schedule))) { _ in
            router.popToRoot()
        }
    }
}
