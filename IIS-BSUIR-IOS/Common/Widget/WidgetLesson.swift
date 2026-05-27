//
//  WidgetLesson.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

struct WidgetLesson: Codable, Identifiable, Hashable {
    let id: String
    let subject: String
    let lessonType: String?
    let startTime: String
    let endTime: String
    let room: String?
    let weekday: String
    let startDate: Date

    var deepLinkURL: URL? {
        var components = URLComponents()
        components.scheme = "iisbsuir"
        components.host = "lesson"
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "startTime", value: startTime),
            URLQueryItem(name: "weekday", value: weekday)
        ]
        return components.url
    }
}
