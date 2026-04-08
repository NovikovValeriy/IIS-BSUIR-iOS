//
//  OmissionsByDateResponseDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct OmissionsByDateResponseDTO: Decodable {
    let lessons: [OmissionLessonDTO]
}

struct OmissionLessonDTO: Decodable {
    // "dd-MM-yyyy"
    let dateString: String
    let id: Int
    let lessonPeriod: LessonPeriodDTO
    let lessonTypeAbbrev: String
    let nameAbbrev: String
    let subGroup: Int
    let students: [OmissionStudentDTO]
}

struct LessonPeriodDTO: Decodable {
    let endTime: String
    let lessonPeriodHours: Int
    let startTime: String
}

struct OmissionStudentDTO: Decodable {
    let fio: String
    let id: Int
    // null if the student was not marked absent
    let omission: StudentOmissionDTO?
}

struct StudentOmissionDTO: Decodable {
    let id: Int
    let missedHours: Int
    let respectfulOmission: Bool
}
