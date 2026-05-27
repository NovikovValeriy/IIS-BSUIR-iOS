//
//  CertificatePlace.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

struct CertificatePlaceCategory {
    let type: String
    let places: [CertificatePlace]
}

struct CertificatePlace: Identifiable {
    let id: Int
    let name: String
}
