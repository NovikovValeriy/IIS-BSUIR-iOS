//
//  ScheduleService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 13.04.26.
//

import Foundation

protocol ScheduleServiceProtocol: AnyObject {
    func fetchGroups() async throws -> [GroupModel]
    func fetchTeachers() async throws -> [Teacher]
    func fetchSchedule(for subject: ScheduleSubject) async throws -> Schedule
    func fetchCurrentWeek() async throws -> Int
}

final class ScheduleService: ScheduleServiceProtocol {
    private let apiClient: any APIClient

    init(apiClient: any APIClient) {
        self.apiClient = apiClient
    }

    func fetchGroups() async throws -> [GroupModel] {
        let dtos: [StudentGroupDTO] = try await apiClient.sendRequest(
            path: "/api/v1/student-groups",
            httpMethod: .GET
        )
        return dtos.map { $0.toDomain() }
    }

    func fetchTeachers() async throws -> [Teacher] {
        let dtos: [EmployeeDTO] = try await apiClient.sendRequest(
            path: "/api/v1/employees/all",
            httpMethod: .GET
        )
        return dtos.map { $0.toDomain() }
    }

    func fetchSchedule(for subject: ScheduleSubject) async throws -> Schedule {
        switch subject {
        case .group(let group):
            let dto: ScheduleResponseDTO = try await apiClient.sendRequest(
                path: "/api/v1/schedule",
                httpMethod: .GET,
                queryParams: ["studentGroup": group.name]
            )
            return dto.toDomain()
        case .teacher(let teacher):
            let dto: ScheduleResponseDTO = try await apiClient.sendRequest(
                path: "/api/v1/employees/schedule/\(teacher.urlId)",
                httpMethod: .GET
            )
            return dto.toDomain()
        }
    }

    func fetchCurrentWeek() async throws -> Int {
        try await apiClient.sendRequest(
            path: "/api/v1/schedule/current-week",
            httpMethod: .GET
        )
    }
}

// MARK: - Mapping

private extension StudentGroupDTO {
    func toDomain() -> GroupModel {
        GroupModel(
            id: id,
            name: name,
            specialityAbbrev: specialityAbbrev,
            specialityName: specialityName,
            facultyAbbrev: facultyAbbrev,
            facultyId: facultyId,
            facultyName: facultyName,
            course: course,
            educationDegree: educationDegree,
            calendarId: calendarId,
            specialityDepartmentEducationFormId: specialityDepartmentEducationFormId
        )
    }
}

private extension EmployeeDTO {
    func toDomain() -> Teacher {
        Teacher(
            id: id,
            firstName: firstName,
            lastName: lastName,
            middleName: middleName,
            photoLink: photoLink,
            degree: degree,
            degreeAbbrev: nil,
            rank: rank,
            email: nil,
            urlId: urlId,
            calendarId: calendarId,
            jobPositions: nil
        )
    }
}

private extension ScheduleEmployeeDTO {
    func toDomain() -> Teacher {
        Teacher(
            id: id,
            firstName: firstName,
            lastName: lastName,
            middleName: middleName,
            photoLink: photoLink,
            degree: degree,
            degreeAbbrev: degreeAbbrev,
            rank: rank,
            email: email,
            urlId: urlId,
            calendarId: calendarId,
            jobPositions: jobPositions
        )
    }
}

private extension LessonStudentGroupDTO {
    func toDomain() -> LessonGroup {
        LessonGroup(
            name: name,
            specialityName: specialityName,
            specialityCode: specialityCode,
            numberOfStudents: numberOfStudents,
            educationDegree: educationDegree
        )
    }
}

private extension LessonDTO {
    func toDomain() -> Lesson {
        Lesson(
            subject: subject,
            subjectFullName: subjectFullName,
            lessonTypeAbbrev: lessonTypeAbbrev,
            startTime: startLessonTime,
            endTime: endLessonTime,
            numSubgroup: numSubgroup,
            weekNumber: weekNumber,
            auditories: auditories ?? [],
            teachers: employees?.map { $0.toDomain() } ?? [],
            groups: studentGroups.map { $0.toDomain() },
            note: note,
            dateLesson: dateLesson,
            startLessonDate: startLessonDate,
            endLessonDate: endLessonDate,
            announcement: announcement,
            split: split
        )
    }
}

private extension ScheduleResponseDTO {
    func toDomain() -> Schedule {
        Schedule(
            weeklyLessons: schedules?.mapValues { $0.map { $0.toDomain() } } ?? [:],
            exams: exams?.map { $0.toDomain() } ?? [],
            semesterEndDate: endDate
        )
    }
}
