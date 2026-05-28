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

    var scheduledNotificationsViewModel: Factory<ScheduledNotificationsViewModel> {
        self { @MainActor in ScheduledNotificationsViewModel(notificationService: self.notificationService()) }
    }

    var appThemeService: Factory<AppThemeService> {
        self { @MainActor in AppThemeService(storage: self.storage()) }.singleton
    }

    var appLanguageService: Factory<AppLanguageService> {
        self { @MainActor in AppLanguageService(storage: self.storage()) }.singleton
    }
}
