//
//  CertificateDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct CertificateDTO: Decodable {
    let certificateType: String
    // "dd.MM.yyyy"
    let dateOrder: String
    let id: Int
    let issueDate: String?
    let number: Int
    let provisionPlace: String
    let rejectionReason: String?
    let status: Int
}
