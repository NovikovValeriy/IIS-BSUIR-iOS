//
//  HeadmanToolsDestination.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

enum HeadmanToolsDestination: Hashable {
    case omissionsByDate(date: Date)
    case markSheet(id: String)
}

enum HeadmanToolsSheet: Identifiable {
    case datePicker

    var id: String { "\(self)" }
}
