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
    var body: some Scene {
        WindowGroup {
            AppView()
                .modelContainer(Container.shared.scheduleModelContainer())
        }
    }
}
