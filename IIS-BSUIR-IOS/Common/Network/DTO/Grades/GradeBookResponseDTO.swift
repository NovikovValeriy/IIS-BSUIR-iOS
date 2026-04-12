//
//  GradeBookResponseDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct GradeBookResponseDTO: Decodable {
    let student: GradeBookStudentDTO
    let students: [GradeBookStudentDTO]?
}

struct GradeBookStudentDTO: Decodable {
    let fio: String
    let id: Int
    let subGroup: Int
    let subGroupStudent: Int?
    let lessons: [GradeBookLessonDTO]
}

struct GradeBookLessonDTO: Decodable {
    // "dd.MM.yyyy"
    let controlPoint: String?
    // "dd.MM.yyyy"
    let dateString: String?
    let gradeBookOmissions: Int?
    let id: Int
    let lessonNameAbbrev: String?
    let lessonTypeAbbrev: String?
    let lessonTypeId: Int?
    let marks: [Int]?
    let subGroup: Int
}
