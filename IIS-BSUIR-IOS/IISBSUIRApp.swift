//
//  IISBSUIRApp.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import SwiftData
import Factory

@main
struct IISBSUIRApp: App {
    @State private var languageService = Container.shared.appLanguageService()

    init() {
        if let data = UserDefaults.standard.data(forKey: StorageKey.appLanguage.rawValue),
           let language = try? JSONDecoder().decode(AppLanguage.self, from: data),
           language != .system {
            Bundle.setLanguageOverride(languageCode: language.rawValue)
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .id(languageService.viewID)
                .modelContainer(Container.shared.scheduleModelContainer())
        }
    }
}
