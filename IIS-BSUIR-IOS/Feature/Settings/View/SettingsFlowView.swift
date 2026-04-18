//
//  SettingsFlowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct SettingsFlowView: View {
    @State private var router: SettingsRouter = Container.shared.settingsRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            SettingsView()
                .navigationDestination(for: SettingsDestination.self) { destination in
                    switch destination {
                    case .appearance:
                        Text("settings.appearance.title")
                            .navigationTitle("settings.appearance.title")
                    case .notifications:
                        Text("settings.notifications_settings.description")
                            .navigationTitle("settings.notifications.title")
                    case .about:
                        Text("settings.about.description")
                            .navigationTitle("settings.about.title")
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
        .onReceive(NotificationCenter.default.publisher(for: .popToRoot(for: .settings))) { _ in
            router.popToRoot()
        }
    }
}
