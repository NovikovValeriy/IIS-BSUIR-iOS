//
//  MarkSheetDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct MarkSheetDTO: Decodable {
    // "dd.MM.yyyy"
    let absentDate: String?
    let certificate: Bool
    // "dd.MM.yyyy"
    let createDate: String?
    let employee: MarkSheetEmployeeDTO?
    // "dd.MM.yyyy"
    let expireDate: String?
    let hours: Double?
    let id: Int
    let markSheetType: MarkSheetTypeDTO?
    let number: String?
    let paymentFormMap: String?
    let price: Double?
    // true = excused, false = unexcused
    let reason: Bool
    let rejectionReason: String?
    let requestValidationDoc: Bool?
    let retakeCount: Int
    let status: String
    let subject: MarkSheetSubjectInfoDTO
    let term: Int
}
