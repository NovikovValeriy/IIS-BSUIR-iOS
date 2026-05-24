//
//  RatingsViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 24.05.26.
//

import Foundation

@Observable
@MainActor
final class RatingsViewModel {
    private let service: any RatingsServiceProtocol
    private let router: DirectoryRouter

    private(set) var faculties: [Faculty] = []
    private(set) var specialities: [RatingSpeciality] = []
    private(set) var courses: [Int] = []
    private(set) var students: [StudentRating] = []

    var selectedFacultyId: Int?
    var selectedSpecialityId: Int?
    var selectedCourse: Int?

    private(set) var isLoadingFaculties = false
    private(set) var isLoadingSpecialities = false
    private(set) var isLoadingCourses = false
    private(set) var isLoadingStudents = false

    init(service: any RatingsServiceProtocol, router: DirectoryRouter) {
        self.service = service
        self.router = router
    }

    func load() async {
        guard !isLoadingFaculties else { return }
        faculties = service.cachedFaculties() ?? []
        isLoadingFaculties = true
        defer { isLoadingFaculties = false }
        do {
            faculties = try await service.fetchFaculties()
        } catch {
            print(error.localizedDescription)
        }
    }

    func didSelectFaculty(_ id: Int?) async {
        specialities = []
        courses = []
        students = []
        selectedSpecialityId = nil
        selectedCourse = nil
        guard let id else { return }
        specialities = service.cachedSpecialities(facultyId: id) ?? []
        isLoadingSpecialities = true
        defer { isLoadingSpecialities = false }
        do {
            specialities = try await service.fetchSpecialities(facultyId: id)
        } catch {
            print(error.localizedDescription)
        }
    }

    func didSelectSpeciality(_ id: Int?) async {
        courses = []
        students = []
        selectedCourse = nil
        guard let id, let facultyId = selectedFacultyId else { return }
        courses = service.cachedCourses(facultyId: facultyId, specialityId: id) ?? []
        isLoadingCourses = true
        defer { isLoadingCourses = false }
        do {
            courses = try await service.fetchCourses(facultyId: facultyId, specialityId: id)
        } catch {
            print(error.localizedDescription)
        }
    }

    func didSelectCourse(_ course: Int?) async {
        students = []
        guard let course, let specialityId = selectedSpecialityId else { return }
        await loadStudents(specialityId: specialityId, course: course)
    }

    func refresh() async {
        guard let course = selectedCourse, let specialityId = selectedSpecialityId else { return }
        await loadStudents(specialityId: specialityId, course: course)
    }

    func didTapStudent(_ student: StudentRating) {
        router.navigateToStudentGrades(student.cardNumber)
    }

    private func loadStudents(specialityId: Int, course: Int) async {
        if let cached = service.cachedRatings(specialityId: specialityId, course: course) {
            students = cached
        }
        isLoadingStudents = true
        defer { isLoadingStudents = false }
        do {
            students = try await service.fetchRatings(specialityId: specialityId, course: course)
        } catch {
            print(error.localizedDescription)
        }
    }
}
