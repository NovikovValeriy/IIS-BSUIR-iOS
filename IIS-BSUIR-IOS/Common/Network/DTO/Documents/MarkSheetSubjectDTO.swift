//
//  MarkSheetSubjectDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct MarkSheetSubjectDTO: Decodable {
    let abbrev: String
    let etId: Int
    let term: Int
    let lessonTypes: [MarkSheetSubjectLessonTypeDTO]
}

struct MarkSheetSubjectLessonTypeDTO: Decodable {
    let abbrev: String
    let focsId: Int?
    let isCourseWork: Bool
    let isExam: Bool
    let isLab: Bool
    let isOffset: Bool
    let isRemote: Bool
    let thId: Int?
}

struct MarkSheetSubjectInfoDTO: Decodable {
    let abbrev: String?
    let focsId: Int?
    let id: Int?
    let lessonTypeAbbrev: String?
    let name: String?
    let term: Int?
    let thId: Int?
}
