//
//  LoginRequestDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct LoginRequestDTO: Encodable {
    let username: String
    let password: String
    let rememberDevice: Bool
}
