//
//  ProfileDestination.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

enum ProfileDestination: Hashable {
    case grades
    case notifications
    case dormitory
    case documents
    case contacts
    case changePassword
}

enum ProfileSheet: Identifiable {
    case editProfile

    var id: String { "\(self)" }
}

enum ProfileConfirmationDialog: Identifiable {
    case logout

    var id: String { "\(self)" }
}
