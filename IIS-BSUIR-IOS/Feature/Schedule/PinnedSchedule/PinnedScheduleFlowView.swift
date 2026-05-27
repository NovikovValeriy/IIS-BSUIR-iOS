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
    @State private var viewModel: PinnedScheduleViewModel = Container.shared.pinnedScheduleViewModel()
    @State private var pinnedService: PinnedScheduleService = Container.shared.pinnedScheduleService()

    var body: some View {
        NavigationStack(path: $router.path) {
            PinnedScheduleView(viewModel: viewModel)
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
