import SwiftUI

enum AppColorScheme: String, CaseIterable, Codable {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .system: return "settings.appearance.theme.system"
        case .light: return "settings.appearance.theme.light"
        case .dark: return "settings.appearance.theme.dark"
        }
    }
}
