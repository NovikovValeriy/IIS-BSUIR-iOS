//
//  Container+Grades.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 07.05.26.
//

import Factory

extension Container {
    var gradesService: Factory<any GradesServiceProtocol> {
        // self { @MainActor in GradesService(apiClient: self.apiClient(), cache: self.profileCacheService()) }.shared
        self { @MainActor in MockGradesService() }.shared
    }

    var gradesViewModel: Factory<GradesViewModel> {
        self { @MainActor in GradesViewModel(gradesService: self.gradesService()) }
    }
}
