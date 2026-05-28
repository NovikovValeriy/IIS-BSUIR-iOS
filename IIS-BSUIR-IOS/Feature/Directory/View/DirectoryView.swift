//
//  DirectoryView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 24.05.26.
//

import SwiftUI
import Factory

private enum Constants {
    enum Icons {
        static let ratings = "chart.bar.fill"
        static let subjects = "book.fill"
        static let departments = "building.2.fill"
    }
}

struct DirectoryView: View {
    @State private var router: DirectoryRouter = Container.shared.directoryRouter()

    var body: some View {
        List {
            Section {
                Button {
                    router.navigateToRatings()
                } label: {
                    Label("directory.ratings".localized(), systemImage: Constants.Icons.ratings)
                }
                Button {
                    router.navigateToSubjects()
                } label: {
                    Label("directory.subjects".localized(), systemImage: Constants.Icons.subjects)
                }
                Button {
                    router.navigateToDepartments()
                } label: {
                    Label("directory.departments".localized(), systemImage: Constants.Icons.departments)
                }
            }
        }
        .navigationTitle("directory.title".localized())
    }
}
