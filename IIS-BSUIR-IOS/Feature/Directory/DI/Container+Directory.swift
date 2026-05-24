//
//  Container+Directory.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 24.05.26.
//

import Factory
import SwiftData

extension Container {
    var directoryRouter: Factory<DirectoryRouter> {
        self { @MainActor in DirectoryRouter() }.shared
    }

    var ratingsCacheService: Factory<RatingsCacheService> {
        self { @MainActor in RatingsCacheService(modelContainer: self.ratingsModelContainer()) }.shared
    }

    var ratingsService: Factory<any RatingsServiceProtocol> {
        self { @MainActor in
            RatingsService(apiClient: self.apiClient(), cache: self.ratingsCacheService())
        }.shared
    }

    var ratingsViewModel: Factory<RatingsViewModel> {
        self { @MainActor in RatingsViewModel(service: self.ratingsService(), router: self.directoryRouter()) }
    }

    // swiftlint:disable force_try
    var ratingsModelContainer: Factory<ModelContainer> {
        self { @MainActor in
            let schema = Schema([CachedRatingEntry.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            if let container = try? ModelContainer(for: schema, configurations: [config]) {
                return container
            }
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallback])
        }.singleton
    }
    // swiftlint:enable force_try
}
