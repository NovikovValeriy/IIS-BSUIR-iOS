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

    var departmentCacheService: Factory<DepartmentCacheService> {
        self { @MainActor in DepartmentCacheService(modelContainer: self.departmentModelContainer()) }.shared
    }

    var departmentService: Factory<any DepartmentServiceProtocol> {
        self { @MainActor in
            DepartmentService(apiClient: self.apiClient(), cache: self.departmentCacheService())
        }.shared
    }

    var departmentsViewModel: Factory<DepartmentsViewModel> {
        self { @MainActor in DepartmentsViewModel(service: self.departmentService(), router: self.directoryRouter()) }
    }

    var subjectsService: Factory<any SubjectsServiceProtocol> {
        self { @MainActor in
            SubjectsService(apiClient: self.apiClient(), cache: self.ratingsCacheService())
        }.shared
    }

    var subjectsViewModel: Factory<SubjectsViewModel> {
        self { @MainActor in SubjectsViewModel(service: self.subjectsService()) }
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

    var departmentModelContainer: Factory<ModelContainer> {
        self { @MainActor in
            let schema = Schema([CachedDepartmentEntry.self])
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
