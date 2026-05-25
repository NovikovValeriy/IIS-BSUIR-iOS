//
//  DepartmentsView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import SwiftUI
import Factory

private enum Constants {
    enum Icons {
        static let empty = "building.2"
    }
}

struct DepartmentsView: View {
    @State private var viewModel: DepartmentsViewModel = Container.shared.departmentsViewModel()

    var body: some View {
        Group {
            if viewModel.departments.isEmpty && viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.departments.isEmpty {
                ContentUnavailableView("departments.empty.title", systemImage: Constants.Icons.empty)
            } else {
                list
            }
        }
        .navigationTitle("directory.departments.title")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var list: some View {
        List(viewModel.departments) { department in
            Button {
                viewModel.didTapDepartment(department)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(department.name)
                        .font(.body)
                        .foregroundStyle(.primary)
                    if department.abbrev != department.name {
                        Text("(\(department.abbrev))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .refreshable { await viewModel.refresh() }
    }
}
