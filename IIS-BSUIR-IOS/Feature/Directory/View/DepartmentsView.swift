//
//  DepartmentsView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import Factory
import SwiftUI

private enum Constants {
    enum Layout {
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
        static let cardSpacing: CGFloat = 2
        static let indentStep: CGFloat = 20
        static let expandButtonSize: CGFloat = 20
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
    }
    enum Icons {
        static let empty = "building.2"
        static let expandChevron = "chevron.right"
        static let navChevron = "chevron.right"
    }
}

struct DepartmentsView: View {
    @State private var viewModel: DepartmentsViewModel = Container.shared.departmentsViewModel()

    var body: some View {
        Group {
            if viewModel.nodes.isEmpty && viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else if viewModel.nodes.isEmpty {
                ContentUnavailableView {
                    Label("departments.empty.title".localized(), systemImage: Constants.Icons.empty)
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else {
                departmentList
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("directory.departments.title".localized())
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var departmentList: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                ForEach(viewModel.flatItems) { item in
                    departmentCard(for: item)
                        .padding(EdgeInsets(
                            top: Constants.Layout.rowInsets.top,
                            leading: Constants.Layout.rowInsets.leading
                            + CGFloat(item.depth)
                            * Constants.Layout.indentStep,
                            bottom: Constants.Layout.rowInsets.bottom,
                            trailing: Constants.Layout.rowInsets.trailing
                        ))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.spring(duration: 0.3), value: viewModel.flatItems.map(\.id))
            .frame(maxWidth: .infinity)
        }
        .refreshable { await viewModel.refresh() }
    }

    // swiftlint:disable function_body_length
    private func departmentCard(for item: FlatDepartmentItem) -> some View {
        HStack(spacing: Constants.Layout.cardPadding) {
            if item.node.hasChildren {
                Button {
                    viewModel.toggleExpanded(item.node)
                } label: {
                    Image(systemName: Constants.Icons.expandChevron)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(viewModel.isExpanded(item.node) ? 90 : 0))
                        .animation(.spring(duration: 0.25), value: viewModel.isExpanded(item.node))
                        .frame(width: Constants.Layout.expandButtonSize, height: Constants.Layout.expandButtonSize)
                }
                .buttonStyle(.borderless)
            } else {
                Spacer()
                    .frame(width: Constants.Layout.expandButtonSize)
            }

            Button {
                viewModel.didTapDepartment(item.node)
            } label: {
                HStack {
                    Text(item.node.number)
                        .font(.callout.weight(.bold))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .lineLimit(1)

                    VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
                        Text(item.node.department.name)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        if item.node.department.abbrev != item.node.department.name {
                            Text("(\(item.node.department.abbrev))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if item.node.hasEmployees {
                        Text("\(item.node.employeeCount)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Image(systemName: Constants.Icons.navChevron)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
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
            .buttonStyle(.plain)
        }
    }
}
// swiftlint:enable function_body_length
