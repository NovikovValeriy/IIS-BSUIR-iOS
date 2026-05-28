import Foundation
import Observation

@Observable
@MainActor
final class AppLanguageService {
    private(set) var current: AppLanguage
    private(set) var viewID: UUID = .init()

    private let storage: any StorageProtocol

    init(storage: any StorageProtocol) {
        self.storage = storage
        let saved: AppLanguage = storage.value(for: .appLanguage) ?? .system
        self.current = saved
        applyLanguage(saved)
    }

    func set(_ language: AppLanguage) {
        guard language != current else { return }
        current = language
        storage.setValue(language, for: .appLanguage)
        applyLanguage(language)
        viewID = .init()
    }

    private func applyLanguage(_ language: AppLanguage) {
        switch language {
        case .system:
            Bundle.setLanguageOverride(languageCode: nil)
        case .russian, .english:
            Bundle.setLanguageOverride(languageCode: language.rawValue)
        }
    }
}
