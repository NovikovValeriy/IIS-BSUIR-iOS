//
//  GradesDestination.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

enum GradesDestination: Hashable {
    case gradeBookDetail(subjectName: String)
    case omissions
}

enum GradesSheet: Identifiable {
    case semesterPicker

    var id: String { "\(self)" }
}
