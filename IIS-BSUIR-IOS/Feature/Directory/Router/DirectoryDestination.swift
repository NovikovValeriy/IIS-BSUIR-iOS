//
//  DirectoryDestination.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 24.05.26.
//

import Foundation

enum DirectoryDestination: Hashable {
    case ratings
    case subjects
    case departments
    case studentGrades(String)
}
