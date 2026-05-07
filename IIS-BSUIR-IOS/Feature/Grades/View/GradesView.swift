//
//  GradesView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 07.05.26.
//

import Factory
import SwiftUI

private enum Constants {
    enum Layout {
        static let pickerPadding = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        static let markSize: CGFloat = 30
        static let markCornerRadius: CGFloat = 6
        static let columnHorizontalPadding: CGFloat = 4
        static let columnsVerticalPadding: CGFloat = 6
        static let columnSpacing: CGFloat = 4
        static let omissionIconSize: CGFloat = 12
    }
    enum Colors {
        static let goodMarkBackground = Color.green.opacity(0.18)
        static let zeroMarkBackground = Color.red.opacity(0.18)
        static let noMarkForeground = Color.secondary
    }
    enum Icons {
        static let markBook = "graduationcap"
        static let omission = "exclamationmark.circle.fill"
    }
    static let lessonTypes: [(abbrev: String, key: LocalizedStringKey)] = [
        ("ЛК", "grades.lesson_type.lk"),
        ("ПЗ", "grades.lesson_type.pz"),
        ("ЛР", "grades.lesson_type.lr")
    ]
}

struct GradesView: View {
    @State private var viewModel = Container.shared.gradesViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.gradeBook != nil {
                contentView
            } else {
                ContentUnavailableView("grades.empty.title", systemImage: Constants.Icons.markBook)
            }
        }
        .navigationTitle("grades.title")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            Picker("", selection: Bindable(viewModel).selectedControlPointIndex) {
                ForEach(viewModel.controlPoints.indices, id: \.self) { index in
                    Text(tabLabel(for: viewModel.controlPoints[index])).tag(index)
                }
            }
            .pickerStyle(.segmented)
            .padding(Constants.Layout.pickerPadding)
            Divider()
            if let controlPoint = viewModel.currentControlPoint {
                subjectList(for: controlPoint)
            }
        }
    }

    private func subjectList(for controlPoint: GradeBookControlPoint) -> some View {
        List {
            ForEach(groupedSubjects(controlPoint), id: \.name) { item in
                SubjectDisclosureRow(subjectName: item.name, groups: item.groups)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }

    private func tabLabel(for point: GradeBookControlPoint) -> String {
        guard point.date != .distantFuture else { return point.displayString }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: point.date)
    }

    private func groupedSubjects(_ controlPoint: GradeBookControlPoint) -> [(name: String, groups: [GradeBookSubjectGroup])] {
        var dict: [String: [GradeBookSubjectGroup]] = [:]
        var order: [String] = []
        for group in controlPoint.subjects {
            if dict[group.subjectName] == nil {
                order.append(group.subjectName)
                dict[group.subjectName] = []
            }
            dict[group.subjectName]!.append(group)
        }
        return order.map { (name: $0, groups: dict[$0]!) }
    }
}

// MARK: - Subject Row

private struct SubjectDisclosureRow: View {
    let subjectName: String
    let groups: [GradeBookSubjectGroup]

    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(Constants.lessonTypes, id: \.abbrev) { lessonType in
                    lessonColumn(for: lessonType)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, Constants.Layout.columnsVerticalPadding)
        } label: {
            HStack {
                Text(subjectName)
                Spacer()
                omissionsBadge
            }
        }
    }

    private func lessonColumn(for lessonType: (abbrev: String, key: LocalizedStringKey)) -> some View {
        let group = groups.first { $0.lessonTypeAbbrev == lessonType.abbrev }
        return VStack(spacing: Constants.Layout.columnSpacing) {
            Text(lessonType.key)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            if let group, !group.marks.isEmpty {
                ForEach(group.marks.indices, id: \.self) { index in
                    MarkBadge(value: group.marks[index])
                }
            } else {
                Text("grades.no_mark")
                    .font(.caption)
                    .foregroundStyle(Constants.Colors.noMarkForeground)
            }
        }
        .padding(.horizontal, Constants.Layout.columnHorizontalPadding)
    }

    @ViewBuilder
    private var omissionsBadge: some View {
        let total = groups.reduce(0) { $0 + $1.totalOmissions }
        if total > 0 {
            Label {
                Text("\(total)")
                    .font(.caption2)
                    .fontWeight(.medium)
            } icon: {
                Image(systemName: Constants.Icons.omission)
                    .font(.system(size: Constants.Layout.omissionIconSize))
            }
            .foregroundStyle(.red)
        }
    }
}

// MARK: - Mark Badge

private struct MarkBadge: View {
    let value: Int

    var body: some View {
        Text("\(value)")
            .font(.subheadline)
            .fontWeight(.semibold)
            .frame(width: Constants.Layout.markSize, height: Constants.Layout.markSize)
            .background(
                value > 0 ? Constants.Colors.goodMarkBackground : Constants.Colors.zeroMarkBackground,
                in: RoundedRectangle(cornerRadius: Constants.Layout.markCornerRadius)
            )
    }
}
