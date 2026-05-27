//
//  LibraryView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import SwiftUI

private enum Constants {
    enum Icons {
        static let library = "books.vertical.fill"
    }
}

struct LibraryView: View {
    var body: some View {
        ContentUnavailableView {
            Label("library.coming_soon", systemImage: Constants.Icons.library)
        } description: {
            Text("library.coming_soon.description")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("profile.library.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
