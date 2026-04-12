//
//  DormitoryApplicationDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct DormitoryApplicationDTO: Decodable {
    // ISO 8601: "yyyy-MM-dd'T'HH:mm:ss.SSS"
    let acceptedDate: String?
    let applicationDate: String?
    let docContent: String?
    let docReference: String?
    let id: Int
    let number: Int
    let numberInQueue: Int?
    let rejectionReason: String?
    let roomInfo: String?
    let settledDate: String?
    let status: String
}
