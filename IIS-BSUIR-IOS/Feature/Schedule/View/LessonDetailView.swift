//
//  LessonDetailView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI

struct LessonDetailView: View {
    let lesson: LessonDTO

    var body: some View {
        ContentUnavailableView(
            lesson.subject ?? "Lesson",
            systemImage: "book.fill",
            description: Text("Lesson detail coming soon.")
        )
        .navigationTitle(lesson.subject ?? "Lesson")
        .navigationBarTitleDisplayMode(.inline)
    }
}
