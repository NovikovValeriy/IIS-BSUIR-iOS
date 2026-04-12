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
                        Text("Appearance")
                            .navigationTitle("Appearance")
                    case .notifications:
                        Text("Notification settings")
                            .navigationTitle("Notifications")
                    case .about:
                        Text("IIS BSUIR — unofficial client")
                            .navigationTitle("About")
                    }
                }
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("OK"))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .popToRoot(for: .settings))) { _ in
            router.popToRoot()
        }
    }
}
