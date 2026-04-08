//
//  ChangePasswordRequestDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct ChangePasswordRequestDTO: Encodable {
    let password: String
    let newPassword: String
}
