//
//  CertificatePlaceDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct CertificatePlaceCategoryDTO: Decodable {
    let type: String
    let places: [CertificatePlaceDTO]
}

struct CertificatePlaceDTO: Decodable {
    let id: Int
    let name: String
    let type: Int
}
