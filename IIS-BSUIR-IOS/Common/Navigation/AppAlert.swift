//
//  AppAlert.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI

struct AppAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String?
    let actions: [AppAlertAction]

    init(title: String, message: String? = nil, actions: [AppAlertAction] = []) {
        self.title = title
        self.message = message
        self.actions = actions
    }

    static func error(_ message: String) -> AppAlert {
        AppAlert(title: "Error", message: message)
    }
}

struct AppAlertAction {
    let title: String
    let role: ButtonRole?
    let handler: () -> Void

    init(title: String, role: ButtonRole? = nil, handler: @escaping () -> Void = {}) {
        self.title = title
        self.role = role
        self.handler = handler
    }

    static func ok(handler: @escaping () -> Void = {}) -> AppAlertAction {
        AppAlertAction(title: "OK", handler: handler)
    }

    static func cancel(handler: @escaping () -> Void = {}) -> AppAlertAction {
        AppAlertAction(title: "Cancel", role: .cancel, handler: handler)
    }
}
