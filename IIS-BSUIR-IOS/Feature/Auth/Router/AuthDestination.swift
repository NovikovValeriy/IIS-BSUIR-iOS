//
//  AuthDestination.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

enum AuthDestination: Hashable {
    case forgotPassword
}

enum AuthSheet: Identifiable {
    case confirmContact

    var id: String { "\(self)" }
}
