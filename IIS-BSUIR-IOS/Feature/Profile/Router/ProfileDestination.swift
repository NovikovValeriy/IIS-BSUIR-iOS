//
//  ProfileDestination.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

enum ProfileDestination: Hashable {}

enum ProfileConfirmationDialog: Identifiable {
    case logout

    var id: String { "\(self)" }
}
