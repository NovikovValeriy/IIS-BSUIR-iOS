//
//  DepartmentEmployeesView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import Factory
import Kingfisher
import SwiftUI
import UIKit

private enum Constants {
    enum Layout {
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
        static let cardSpacing: CGFloat = 4
        static let cardHSpacing: CGFloat = 12
        static let avatarSize: CGFloat = 60
        static let phoneSpacing: CGFloat = 2
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
    }
    enum Icons {
        static let personPlaceholder = "person.circle.fill"
        static let phone = "phone.fill"
        static let empty = "person.slash"
    }
}

struct DepartmentEmployeesView: View {
    @State private var viewModel: DepartmentEmployeesViewModel

    init(department: Department) {
        _viewModel = State(wrappedValue: DepartmentEmployeesViewModel(
            service: Container.shared.departmentService(),
            department: department
        ))
    }

    var body: some View {
        Group {
            if viewModel.employees.isEmpty && viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else if viewModel.employees.isEmpty {
                ContentUnavailableView {
                    Label("department.employees.empty.title".localized(), systemImage: Constants.Icons.empty)
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else {
                employeeList
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(viewModel.department.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var employeeList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.employees) { employee in
                    EmployeeCardView(employee: employee)
                        .padding(Constants.Layout.rowInsets)
                }
            }
        }
        .refreshable { await viewModel.refresh() }
    }
}

private struct EmployeeCardView: View {
    let employee: DepartmentEmployee

    var body: some View {
        HStack(alignment: .center, spacing: Constants.Layout.cardHSpacing) {
            avatarView

            VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
                Text(employee.fio)
                    .font(.body.weight(.semibold))
                    .lineLimit(2)

                if let position = employee.jobPosition {
                    Text(position)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if !employee.phones.isEmpty {
                    VStack(alignment: .leading, spacing: Constants.Layout.phoneSpacing) {
                        ForEach(employee.phones, id: \.self) { phone in
                            phoneButton(phone)
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(Constants.Layout.cardPadding)
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .shadow(
            color: Constants.Colors.shadowColor,
            radius: Constants.Layout.shadowRadius,
            x: 0,
            y: Constants.Layout.shadowOffsetY
        )
    }

    @ViewBuilder
    private var avatarView: some View {
        let size = Constants.Layout.avatarSize
        if let urlString = employee.photoLink, let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .placeholder {
                    Image(systemName: Constants.Icons.personPlaceholder)
                        .resizable()
                        .foregroundStyle(Color.secondary)
                }
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            Image(systemName: Constants.Icons.personPlaceholder)
                .resizable()
                .foregroundStyle(Color.secondary)
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }

    private func phoneButton(_ phone: String) -> some View {
        Button {
            guard let url = URL(string: "tel:\(phone.filter { !$0.isWhitespace })") else { return }
            UIApplication.shared.open(url)
        } label: {
            Label(phone, systemImage: Constants.Icons.phone)
                .font(.caption)
        }
        .buttonStyle(.borderless)
        .contextMenu {
            Button {
                UIPasteboard.general.string = phone
            } label: {
                Label("common.copy".localized(), systemImage: "doc.on.doc")
            }
        }
    }
}
