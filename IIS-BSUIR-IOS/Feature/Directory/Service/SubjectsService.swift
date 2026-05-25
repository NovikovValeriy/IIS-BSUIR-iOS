//
//  SubjectsService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 26.05.26.
//

import Foundation

@MainActor
protocol SubjectsServiceProtocol: AnyObject {
    func cachedFaculties() -> [Faculty]?
    func fetchFaculties() async throws -> [Faculty]
    func cachedSpecialities(facultyId: Int) -> [RatingSpeciality]?
    func fetchSpecialities(facultyId: Int) async throws -> [RatingSpeciality]
    func cachedCourses(facultyId: Int, specialityId: Int) -> [Int]?
    func fetchCourses(facultyId: Int, specialityId: Int) async throws -> [Int]
    func cachedDisciplines(specialityId: Int, course: Int) -> [Discipline]?
    func fetchDisciplines(specialityId: Int, course: Int) async throws -> [Discipline]
}

@MainActor
final class SubjectsService: SubjectsServiceProtocol {
    private let apiClient: any APIClient
    private let cache: RatingsCacheService

    init(apiClient: any APIClient, cache: RatingsCacheService) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func cachedFaculties() -> [Faculty]? {
        cache.load([Faculty].self, forKey: "faculties")
    }

    func fetchFaculties() async throws -> [Faculty] {
        let dtos: [FacultyDTO] = try await apiClient.sendRequest(path: "/schedule/faculties", httpMethod: .GET)
        let faculties = dtos.map { Faculty(id: $0.id, name: $0.text) }
        cache.save(faculties, forKey: "faculties")
        return faculties
    }

    func cachedSpecialities(facultyId: Int) -> [RatingSpeciality]? {
        cache.load([RatingSpeciality].self, forKey: "specialities:\(facultyId)")
    }

    func fetchSpecialities(facultyId: Int) async throws -> [RatingSpeciality] {
        let dtos: [RatingSpecialityDTO] = try await apiClient.sendRequest(
            path: "/rating/specialities",
            httpMethod: .GET,
            queryParams: ["facultyId": "\(facultyId)"]
        )
        let specialities = dtos.map { RatingSpeciality(id: $0.id, name: $0.text) }
        cache.save(specialities, forKey: "specialities:\(facultyId)")
        return specialities
    }

    func cachedCourses(facultyId: Int, specialityId: Int) -> [Int]? {
        cache.load([Int].self, forKey: "courses:\(facultyId):\(specialityId)")
    }

    func fetchCourses(facultyId: Int, specialityId: Int) async throws -> [Int] {
        let dtos: [RatingCourseDTO] = try await apiClient.sendRequest(
            path: "/rating/courses",
            httpMethod: .GET,
            queryParams: ["facultyId": "\(facultyId)", "specialityId": "\(specialityId)"]
        )
        let courses = dtos.map { $0.course }.sorted()
        cache.save(courses, forKey: "courses:\(facultyId):\(specialityId)")
        return courses
    }

    func cachedDisciplines(specialityId: Int, course: Int) -> [Discipline]? {
        cache.load([Discipline].self, forKey: "disciplines:\(specialityId):\(course)")
    }

    func fetchDisciplines(specialityId: Int, course: Int) async throws -> [Discipline] {
        let dtos: [DisciplineDTO] = try await apiClient.sendRequest(
            path: "/list-disciplines",
            httpMethod: .GET,
            queryParams: ["id": "\(specialityId)", "course": "\(course)", "isForeign": "false"]
        )
        let disciplines = dtos
            .filter { $0.hours > 0 }
            .sorted { $0.hours > $1.hours }
            .map { Discipline(name: $0.name, hours: $0.hours) }
        cache.save(disciplines, forKey: "disciplines:\(specialityId):\(course)")
        return disciplines
    }
}
