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
            "Grades",
            systemImage: "chart.bar.fill",
            description: Text("Grades screen coming soon.")
        )
        .navigationTitle("Grades")
    }
}
