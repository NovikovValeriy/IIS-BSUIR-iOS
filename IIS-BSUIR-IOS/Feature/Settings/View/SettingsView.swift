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
                Button("settings.appearance".localized()) { router.push(.appearance) }
                Button("settings.language".localized()) { router.push(.language) }
                Button("settings.notifications".localized()) { router.push(.notifications) }
            }
        }
        .navigationTitle("settings.title".localized())
    }
}
