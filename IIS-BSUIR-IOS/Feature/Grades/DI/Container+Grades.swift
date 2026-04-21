//
//  Container+Grades.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 21.04.26.
//

import Factory

extension Container {
    var gradesService: Factory<any GradesServiceProtocol> {
        self { @MainActor in GradesService(apiClient: self.apiClient()) }.shared
    }

    var gradeBookViewModel: Factory<GradeBookViewModel> {
        self { @MainActor in GradeBookViewModel(gradesService: self.gradesService()) }
    }
}
