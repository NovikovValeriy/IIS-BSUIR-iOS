//
//  SettingsView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct SettingsView: View {
    @State private var router: SettingsRouter = Container.shared.settingsRouter()

    var body: some View {
        List {
            Section {
                Button("Appearance") { router.push(.appearance) }
                Button("Notifications") { router.push(.notifications) }
            }
            Section {
                Button("About") { router.push(.about) }
            }
        }
        .navigationTitle("Settings")
    }
}
