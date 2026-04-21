//
//  GradeBookViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 21.04.26.
//

import Foundation

@Observable
@MainActor
final class GradeBookViewModel {
    private(set) var markBook: MarkBook?
    private(set) var isLoading: Bool = false
    var selectedSemesterIndex: Int = 0

    var semesters: [MarkBookSemester] { markBook?.semesters ?? [] }

    var currentSemester: MarkBookSemester? {
        guard semesters.indices.contains(selectedSemesterIndex) else { return nil }
        return semesters[selectedSemesterIndex]
    }

    private let gradesService: any GradesServiceProtocol

    init(gradesService: any GradesServiceProtocol) {
        self.gradesService = gradesService
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        markBook = try? await gradesService.fetchMarkBook()
    }
}
