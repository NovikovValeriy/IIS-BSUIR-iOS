//
//  User.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 16.04.26.
//

struct User {
    let username: String
    let fio: String
    let group: String
    let email: String?
    let phone: String
    let photoUrl: String?
    let isGroupHead: Bool
    let canStudentNote: Bool
    let hasNotConfirmedContact: Bool
    let authorities: [String]
}
