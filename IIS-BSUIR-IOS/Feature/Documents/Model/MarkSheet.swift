//
//  MarkSheet.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

struct MarkSheet: Identifiable, Codable {
    let id: Int
    let number: String?
    let status: String
    let submitDate: String?
    let absentDate: String?
    let expireDate: String?
    let hours: Double
    let retakeCount: Int
    let price: Double
    let isRespectful: Bool
    let rejectionReason: String?
    let subjectName: String?
    let subjectAbbrev: String?
    let lessonTypeAbbrev: String?
    let teacherFio: String?
    let typeName: String?
}
