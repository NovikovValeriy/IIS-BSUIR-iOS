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
                        AppearanceView()
                    case .language:
                        LanguageView()
                    case .notifications:
                        ScheduledNotificationsView()
                    }
                }
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("common.ok".localized()))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .popToRoot(for: .settings))) { _ in
            router.popToRoot()
        }
    }
}
