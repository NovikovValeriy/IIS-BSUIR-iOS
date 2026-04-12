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
            "Notifications",
            systemImage: "bell.fill",
            description: Text("Notifications screen coming soon.")
        )
        .navigationTitle("Notifications")
    }
}
