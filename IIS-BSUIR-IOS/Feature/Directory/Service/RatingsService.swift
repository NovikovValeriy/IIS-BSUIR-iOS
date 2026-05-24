//
//  RatingsService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 24.05.26.
//

import Foundation

@MainActor
protocol RatingsServiceProtocol: AnyObject {
    func cachedFaculties() -> [Faculty]?
    func fetchFaculties() async throws -> [Faculty]
    func cachedSpecialities(facultyId: Int) -> [RatingSpeciality]?
    func fetchSpecialities(facultyId: Int) async throws -> [RatingSpeciality]
    func cachedCourses(facultyId: Int, specialityId: Int) -> [Int]?
    func fetchCourses(facultyId: Int, specialityId: Int) async throws -> [Int]
    func cachedRatings(specialityId: Int, course: Int) -> [StudentRating]?
    func fetchRatings(specialityId: Int, course: Int) async throws -> [StudentRating]
    func fetchStudentGradeBook(cardNumber: String) async throws -> GradeBook
}

@MainActor
final class RatingsService: RatingsServiceProtocol {
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

    func cachedRatings(specialityId: Int, course: Int) -> [StudentRating]? {
        cache.load([StudentRating].self, forKey: "ratings:\(specialityId):\(course)")
    }

    func fetchRatings(specialityId: Int, course: Int) async throws -> [StudentRating] {
        let dtos: [StudentRatingDTO] = try await apiClient.sendRequest(
            path: "/rating",
            httpMethod: .GET,
            queryParams: ["sdef": "\(specialityId)", "course": "\(course)"]
        )
        let ratings = dtos
            .map { StudentRating(cardNumber: $0.studentCardNumber, average: $0.average, omissionHours: $0.hours) }
            .sorted { $0.average > $1.average }
        cache.save(ratings, forKey: "ratings:\(specialityId):\(course)")
        return ratings
    }

    func fetchStudentGradeBook(cardNumber: String) async throws -> GradeBook {
        let dto: GradeBookStudentDTO = try await apiClient.sendRequest(
            path: "/rating/studentRating",
            httpMethod: .GET,
            queryParams: ["studentCardNumber": cardNumber]
        )
        return dto.toGradeBook()
    }
}

// MARK: - Adapter for GradesView

@MainActor
final class StudentGradesAdapter: GradesServiceProtocol {
    private let cardNumber: String
    private let service: any RatingsServiceProtocol

    init(cardNumber: String, service: any RatingsServiceProtocol) {
        self.cardNumber = cardNumber
        self.service = service
    }

    func fetchGradeBook() async throws -> GradeBook {
        try await service.fetchStudentGradeBook(cardNumber: cardNumber)
    }
}

// MARK: - GradeBookStudentDTO mapping

extension GradeBookStudentDTO {
    func toGradeBook() -> GradeBook {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        let mappedLessons = lessons
            .compactMap { lessonDTO -> GradeBookLesson? in
                guard let subjectName = lessonDTO.lessonNameAbbrev else { return nil }
                return GradeBookLesson(
                    id: lessonDTO.id,
                    subjectName: subjectName,
                    lessonTypeAbbrev: lessonDTO.lessonTypeAbbrev,
                    subGroup: lessonDTO.subGroup,
                    marks: lessonDTO.marks ?? [],
                    omissions: lessonDTO.gradeBookOmissions ?? 0,
                    isRespectfulOmission: lessonDTO.isRespectfulOmission ?? false,
                    date: lessonDTO.dateString.flatMap { dateFormatter.date(from: $0) },
                    controlPointDate: lessonDTO.controlPoint.flatMap { dateFormatter.date(from: $0) },
                    controlPointString: lessonDTO.controlPoint ?? ""
                )
            }
            .sorted { lhs, rhs in
                switch (lhs.date, rhs.date) {
                case (nil, nil): return lhs.subjectName < rhs.subjectName
                case (nil, _): return true
                case (_, nil): return false
                case let (lhs?, rhs?): return lhs < rhs
                }
            }

        return GradeBook(studentName: fio, subGroup: subGroup, lessons: mappedLessons)
    }
}
