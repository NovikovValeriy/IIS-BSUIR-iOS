//
//  LibraryView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 28.05.26.
//

import SwiftUI
import Factory

private enum Constants {
    enum Icons {
        static let empty = "books.vertical"
    }
}

struct LibraryView: View {
    @State private var viewModel: LibraryViewModel = Container.shared.libraryViewModel()

    var body: some View {
        Group {
            if viewModel.hasLoaded {
                ContentUnavailableView {
                    Label("library.empty.title".localized(), systemImage: Constants.Icons.empty)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("library.title".localized())
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}
