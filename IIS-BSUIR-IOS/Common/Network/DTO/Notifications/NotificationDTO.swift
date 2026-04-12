//
//  NotificationDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct NotificationDTO: Decodable {
    // "dd.MM.yyyy HH:mm:ss"
    let date: String
    let id: Int
    let isViewed: Bool
    let message: String
    // "SUCCESS", "FAILURE", "INFO"
    let type: String
}
