//
//  NotificationsResponseDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct NotificationsResponseDTO: Decodable {
    let hasNext: Bool
    let notifications: [NotificationDTO]
    let totalElements: Int
}
