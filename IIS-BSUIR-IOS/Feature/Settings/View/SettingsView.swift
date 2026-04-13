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
                Button("settings.appearance") { router.push(.appearance) }
                Button("settings.notifications") { router.push(.notifications) }
            }
            Section {
                Button("settings.about") { router.push(.about) }
            }
        }
        .navigationTitle("settings.title")
    }
}
