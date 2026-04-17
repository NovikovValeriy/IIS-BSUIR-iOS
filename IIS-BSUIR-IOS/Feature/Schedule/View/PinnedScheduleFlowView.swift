//
//  PinnedScheduleFlowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 17.04.26.
//

import SwiftUI
import Factory

struct PinnedScheduleFlowView: View {
    @State private var router: ScheduleRouter = Container.shared.pinnedScheduleRouter()
    @State private var viewModel: ScheduleViewModel = Container.shared.pinnedScheduleViewModel()
    @State private var pinnedService: PinnedScheduleService = Container.shared.pinnedScheduleService()

    var body: some View {
        NavigationStack(path: $router.path) {
            ScheduleView(viewModel: viewModel)
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
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("common.ok"))
            )
        }
        .onChange(of: pinnedService.subject) { _, newSubject in
            viewModel.pinnedSubjectDidChange(to: newSubject)
        }
        .onReceive(NotificationCenter.default.publisher(for: .popToRoot(for: .pinnedSchedule))) { _ in
            router.popToRoot()
        }
    }
}
