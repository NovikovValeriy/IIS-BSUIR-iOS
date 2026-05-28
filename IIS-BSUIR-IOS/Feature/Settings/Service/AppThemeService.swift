import Observation

@Observable
@MainActor
final class AppThemeService {
    private(set) var current: AppColorScheme

    private let storage: any StorageProtocol

    init(storage: any StorageProtocol) {
        self.storage = storage
        self.current = storage.value(for: .appColorScheme) ?? .system
    }

    func set(_ scheme: AppColorScheme) {
        current = scheme
        storage.setValue(scheme, for: .appColorScheme)
    }
}
