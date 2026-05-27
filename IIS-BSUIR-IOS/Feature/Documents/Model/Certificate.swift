//
//  Certificate.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

struct Certificate: Identifiable, Codable {
    let id: Int
    let number: Int
    let type: String
    let orderDate: String
    let issueDate: String?
    let deliveryPlace: String
    let status: CertificateStatus
    let rejectionReason: String?
}

enum CertificateStatus: Int, Codable {
    case printed = 1
    case processing = 2
    case rejected = 3
    case unknown = 0
}
