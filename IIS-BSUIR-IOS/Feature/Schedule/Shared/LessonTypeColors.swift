//
//  LessonTypeColors.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 18.04.26.
//

import SwiftUI

enum LessonTypeColors {
    private static let map: [String: Color] = [
        "ЛК": .green,
        "ПЗ": .yellow,
        "ЛР": .red,
        "Экзамен": .purple,
        "Консультация": .brown
    ]

    static func color(forType type: String?, isAnnouncement: Bool) -> Color {
        if isAnnouncement { return .gray }
        guard let type else { return .gray }
        return map[type] ?? .gray
    }
}
