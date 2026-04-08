//
//  OrderCertificateRequestDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct OrderCertificateRequestDTO: Encodable {
    let certificateCount: Int
    let certificateRequestDto: CertificateRequestDetailsDTO
}

struct CertificateRequestDetailsDTO: Encodable {
    let certificateType: String
    let provisionPlace: String
}
