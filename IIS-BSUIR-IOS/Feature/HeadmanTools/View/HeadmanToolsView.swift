//
//  HeadmanToolsView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct HeadmanToolsView: View {
    @State private var viewModel: HeadmanToolsViewModel = Container.shared.headmanToolsViewModel()

    var body: some View {
        ContentUnavailableView(
            "Headman Tools",
            systemImage: "person.2.fill",
            description: Text("Headman tools coming soon.")
        )
        .navigationTitle("Headman Tools")
    }
}
