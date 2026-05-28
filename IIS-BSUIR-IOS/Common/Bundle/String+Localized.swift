//
//  String+Localized.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 28.05.26.
//

import Foundation

extension String {
    func localized() -> String {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.appLanguage.rawValue),
              let language = try? JSONDecoder().decode(AppLanguage.self, from: data),
              language != .system,
              let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: "")
        }
        return bundle.localizedString(forKey: self, value: nil, table: nil)
    }
}
