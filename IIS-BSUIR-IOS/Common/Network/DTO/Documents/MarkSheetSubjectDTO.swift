//
//  MarkSheetSubjectDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

// Used in GET mark-sheet/subjects response
struct MarkSheetSubjectDTO: Decodable {
    let abbrev: String
    let etId: Int
    let term: Int
    let lessonTypes: [MarkSheetSubjectLessonTypeDTO]
}

struct MarkSheetSubjectLessonTypeDTO: Decodable {
    let abbrev: String
    // Non-null for exam/credit subjects
    let focsId: Int?
    let isCourseWork: Bool
    let isExam: Bool
    let isLab: Bool
    let isOffset: Bool
    let isRemote: Bool
    // Non-null for lab/practice subjects
    let thId: Int?
}

// Used in GET mark-sheet response (subject nested in MarkSheetDTO)
struct MarkSheetSubjectInfoDTO: Decodable {
    let abbrev: String?
    let focsId: Int?
    let id: Int?
    let lessonTypeAbbrev: String?
    let name: String?
    let term: Int?
    let thId: Int?
}
