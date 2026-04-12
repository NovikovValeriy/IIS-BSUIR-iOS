//
//  GroupInfoResponseDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct GroupInfoResponseDTO: Decodable {
    let groupInfoStudentDto: [GroupInfoStudentDTO]
    let numberOfGroup: String
    let studentGroupCuratorDto: GroupCuratorDTO
}

struct GroupInfoStudentDTO: Decodable {
    let fio: String
    let position: String
    let urlId: String
}

struct GroupCuratorDTO: Decodable {
    let email: String
    let fio: String
    let phone: String
    let position: String
    let urlId: String
}
