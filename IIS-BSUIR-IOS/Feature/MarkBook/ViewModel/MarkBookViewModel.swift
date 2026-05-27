//
//  MarkBookViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 21.04.26.
//

import Foundation

@Observable
@MainActor
final class MarkBookViewModel {
    private(set) var markBook: MarkBook?
    private(set) var isLoading: Bool = false
    var selectedSemesterIndex: Int = 0

    var semesters: [MarkBookSemester] { markBook?.semesters ?? [] }

    var currentSemester: MarkBookSemester? {
        guard semesters.indices.contains(selectedSemesterIndex) else { return nil }
        return semesters[selectedSemesterIndex]
    }

    private let markBookService: any MarkBookServiceProtocol

    init(markBookService: any MarkBookServiceProtocol) {
        self.markBookService = markBookService
        self.markBook = markBookService.cachedMarkBook()
    }

    func load() async {
        guard !isLoading else { return }
        if markBook == nil {
            isLoading = true
        }
        defer { isLoading = false }
        markBook = try? await markBookService.fetchMarkBook()
    }
}
