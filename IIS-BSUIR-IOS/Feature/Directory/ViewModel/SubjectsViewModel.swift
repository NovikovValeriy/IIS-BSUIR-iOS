//
//  SubjectsViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 26.05.26.
//

import Foundation

@Observable
@MainActor
final class SubjectsViewModel {
    private let service: any SubjectsServiceProtocol

    private(set) var faculties: [Faculty] = []
    private(set) var specialities: [RatingSpeciality] = []
    private(set) var courses: [Int] = []
    private(set) var disciplines: [Discipline] = []

    var semesters: [Int] {
        guard let course = selectedCourse else { return [] }
        let first = (course - 1) * 2 + 1
        return [first, first + 1]
    }

    var selectedFacultyId: Int?
    var selectedSpecialityId: Int?
    var selectedCourse: Int?
    var selectedSemester: Int?

    private(set) var isLoadingFaculties = false
    private(set) var isLoadingSpecialities = false
    private(set) var isLoadingCourses = false
    private(set) var isLoadingDisciplines = false

    init(service: any SubjectsServiceProtocol) {
        self.service = service
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
        disciplines = []
        selectedSpecialityId = nil
        selectedCourse = nil
        selectedSemester = nil
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
        disciplines = []
        selectedCourse = nil
        selectedSemester = nil
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
        disciplines = []
        selectedSemester = nil
        guard let course, let specialityId = selectedSpecialityId else { return }
        await loadDisciplines(specialityId: specialityId, course: course, term: nil)
    }

    func didSelectSemester(_ term: Int?) async {
        disciplines = []
        guard let course = selectedCourse, let specialityId = selectedSpecialityId else { return }
        await loadDisciplines(specialityId: specialityId, course: course, term: term)
    }

    func refresh() async {
        guard let course = selectedCourse, let specialityId = selectedSpecialityId else { return }
        await loadDisciplines(specialityId: specialityId, course: course, term: selectedSemester)
    }

    private func loadDisciplines(specialityId: Int, course: Int, term: Int?) async {
        if let cached = service.cachedDisciplines(specialityId: specialityId, course: course, term: term) {
            disciplines = cached
        }
        isLoadingDisciplines = true
        defer { isLoadingDisciplines = false }
        do {
            disciplines = try await service.fetchDisciplines(specialityId: specialityId, course: course, term: term)
        } catch {
            print(error.localizedDescription)
        }
    }
}
