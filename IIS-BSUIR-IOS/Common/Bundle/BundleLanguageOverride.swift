import Foundation
import ObjectiveC

private var overrideBundleKey: UInt8 = 0

final class LanguageOverrideBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let bundle = objc_getAssociatedObject(self, &overrideBundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static func setLanguageOverride(languageCode: String?) {
        if !(Bundle.main is LanguageOverrideBundle) {
            object_setClass(Bundle.main, LanguageOverrideBundle.self)
        }
        let overrideBundle: Bundle?
        if let code = languageCode,
           let path = Bundle.main.path(forResource: code, ofType: "lproj") {
            overrideBundle = Bundle(path: path)
        } else {
            overrideBundle = nil
        }
        objc_setAssociatedObject(
            Bundle.main,
            &overrideBundleKey,
            overrideBundle,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}
