//
//  LoginResponseDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct LoginResponseDTO: Decodable {
    let authorities: [String]
    let canStudentNote: Bool
    let email: String?
    let fio: String
    let group: String
    let hasNotConfirmedContact: Bool
    let isGroupHead: Bool
    let phone: String
    let photoUrl: String?
    let username: String
}
