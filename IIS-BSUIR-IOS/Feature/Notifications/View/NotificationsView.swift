//
//  NotificationsView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct NotificationsView: View {
    @State private var viewModel: NotificationsViewModel = Container.shared.notificationsViewModel()

    var body: some View {
        ContentUnavailableView(
            "notifications.title",
            systemImage: "bell.fill",
            description: Text("notifications.coming_soon")
        )
        .navigationTitle("notifications.title")
    }
}
