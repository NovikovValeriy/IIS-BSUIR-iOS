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

    var body: some View {
        NavigationStack(path: $router.path) {
            ScheduleView()
                .navigationDestination(for: ScheduleDestination.self) { destination in
                    switch destination {
                    case .lessonDetail(let lesson):
                        LessonDetailView(lesson: lesson)
                    case .employeeSchedule(let employeeId):
                        Text("Employee schedule: \(employeeId)")
                            .navigationTitle("Employee Schedule")
                    case .groupSchedule(let groupId):
                        Text("Group schedule: \(groupId)")
                            .navigationTitle("Group Schedule")
                    }
                }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            switch sheet {
            case .filterOptions:
                Text("Filter options — coming soon")
                    .presentationDetents([.medium])
            case .weekPicker:
                Text("Week picker — coming soon")
                    .presentationDetents([.height(300)])
            }
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("OK"))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .popToRoot(for: .schedule))) { _ in
            router.popToRoot()
        }
    }
}
