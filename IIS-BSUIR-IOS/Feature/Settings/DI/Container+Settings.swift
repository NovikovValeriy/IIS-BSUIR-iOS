//
//  Container+Settings.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Factory

extension Container {
    var settingsRouter: Factory<SettingsRouter> {
        self { @MainActor in SettingsRouter() }.shared
    }
}
