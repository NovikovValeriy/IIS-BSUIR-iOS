//
//  MarkSheetTypeDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct MarkSheetTypeDTO: Codable {
    let coefficient: Double?
    let fullName: String
    let id: Int
    let isCourseWork: Bool
    let isExam: Bool
    let isLab: Bool
    let isOffset: Bool
    let isRemote: Bool
    let price: Double?
    let shortName: String
}
