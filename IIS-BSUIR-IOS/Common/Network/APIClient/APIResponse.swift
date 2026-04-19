//
//  APIResponse.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

import Foundation

struct APIResponse {
    let statusCode: Int
    let data: Data
    let headers: [String: String]
}

extension APIResponse {
    var jsessionId: String? {
        guard let cookie = headers["Set-Cookie"] else { return nil }
        return cookie
            .components(separatedBy: ";")
            .first?
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: "=")
            .dropFirst()
            .joined(separator: "=")
            .nonEmpty
    }
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}
