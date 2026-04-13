//
//  GradesView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct GradesView: View {
    @State private var viewModel: GradesViewModel = Container.shared.gradesViewModel()

    var body: some View {
        ContentUnavailableView(
            "grades.title",
            systemImage: "chart.bar.fill",
            description: Text("grades.coming_soon")
        )
        .navigationTitle("grades.title")
    }
}
