//
//  Container+MarkBook.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 21.04.26.
//

import Factory

extension Container {
    var markBookService: Factory<any MarkBookServiceProtocol> {
        self { @MainActor in MarkBookService(apiClient: self.apiClient()) }.shared
    }

    var markBookViewModel: Factory<MarkBookViewModel> {
        self { @MainActor in MarkBookViewModel(markBookService: self.markBookService()) }
    }
}
