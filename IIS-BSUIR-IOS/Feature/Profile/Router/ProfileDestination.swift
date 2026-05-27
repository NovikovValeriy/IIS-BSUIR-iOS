//
//  ProfileDestination.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

enum ProfileDestination: Hashable {
    case markBook
    case grades
    case certificates
    case groupInfo
    case announcements
    case dormitory
    case penalties
    case activity
}

enum ProfileConfirmationDialog: Identifiable {
    case logout

    var id: String { "\(self)" }
}
