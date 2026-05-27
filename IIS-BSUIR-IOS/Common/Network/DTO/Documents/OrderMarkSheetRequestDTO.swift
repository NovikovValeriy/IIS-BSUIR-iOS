//
//  OrderMarkSheetRequestDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct OrderMarkSheetRequestDTO: Encodable {
    let price: Double
    let markSheetType: MarkSheetTypeDTO
    let reason: Int
    let hours: String
    let subject: MarkSheetSubjectRefDTO
    // "dd.MM.yyyy"
    let absentDate: String
    let employee: MarkSheetEmployeeDTO
}

struct MarkSheetSubjectRefDTO: Encodable {
    let focsId: Int?
    let thId: Int?
}
