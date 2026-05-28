import SwiftUI

enum AppLanguage: String, CaseIterable, Codable {
    case system
    case russian = "ru"
    case english = "en"

    var title: String {
        switch self {
        case .system: return "settings.language.system".localized()
        case .russian: return "settings.language.russian".localized()
        case .english: return "settings.language.english".localized()
        }
    }
}
