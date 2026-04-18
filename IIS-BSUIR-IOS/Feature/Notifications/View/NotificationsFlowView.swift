//
//  NotificationsFlowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct NotificationsFlowView: View {
    @State private var router: NotificationsRouter = Container.shared.notificationsRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            NotificationsView()
                .navigationDestination(for: NotificationsDestination.self) { destination in
                    switch destination {
                    case .notificationDetail(let id):
                        Text("notifications.notification_detail \(id)")
                            .navigationTitle("notifications.notification.title")
                    }
                }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            switch sheet {
            case .filterOptions:
                Text("notifications.filter.coming_soon")
                    .presentationDetents([.medium])
            }
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("common.ok"))
            )
        }
    }
}
