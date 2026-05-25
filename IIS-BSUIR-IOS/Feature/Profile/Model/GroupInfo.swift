//
//  GroupInfo.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

struct GroupInfo: Codable {
    let groupNumber: String
    let curator: GroupCurator
    let students: [GroupStudent]
}

struct GroupCurator: Codable {
    let fio: String
    let phone: String
    let email: String
}

struct GroupStudent: Identifiable, Codable {
    var id: String { fio }
    let fio: String
    let position: String?
}
