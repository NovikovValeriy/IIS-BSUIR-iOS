//
//  NotificationMode.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

enum NotificationMode: String, CaseIterable, Identifiable {
    case once
    case weekly

    var id: String { rawValue }

    var localizedKey: String.LocalizationValue {
        switch self {
        case .once: "lesson.detail.notification.mode.once"
        case .weekly: "lesson.detail.notification.mode.weekly"
        }
    }
}
