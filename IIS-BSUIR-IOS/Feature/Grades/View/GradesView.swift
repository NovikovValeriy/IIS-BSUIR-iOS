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
        static let summaryHorizontalPadding: CGFloat = 16
        static let summaryVerticalPadding: CGFloat = 10
        static let pickerVerticalPadding: CGFloat = 8
        static let pickerHorizontalPadding: CGFloat = 16
        static let pickerSpacing: CGFloat = 8
        static let pillHorizontalPadding: CGFloat = 14
        static let pillVerticalPadding: CGFloat = 7
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
        static let cardRowSpacing: CGFloat = 8
        static let markSpacing: CGFloat = 4
        static let markSize: CGFloat = 28
        static let markCornerRadius: CGFloat = 6
        static let typeColumnWidth: CGFloat = 32
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
        static let goodMarkBackground = Color.green.opacity(0.18)
        static let zeroMarkBackground = Color.red.opacity(0.18)
    }
    enum Icons {
        static let grades = "list.number"
        static let omission = "exclamationmark.circle.fill"
    }
    static let lessonTypes: [(abbrev: String, key: LocalizedStringKey)] = [
        ("ЛК", "grades.lesson_type.lk"),
        ("ПЗ", "grades.lesson_type.pz"),
        ("ЛР", "grades.lesson_type.lr")
    ]
}

private extension Double {
    var formattedAverage: String {
        var result = String(format: "%.2f", self)
        while result.hasSuffix("0") { result.removeLast() }
        if result.hasSuffix(".") { result.removeLast() }
        return result
    }
}

struct GradesView: View {
    @State private var viewModel = Container.shared.gradesViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.gradeBook != nil {
                loadedView
            } else {
                ContentUnavailableView("grades.empty.title", systemImage: Constants.Icons.grades)
            }
        }
        .navigationTitle("grades.title")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var loadedView: some View {
        VStack(spacing: 0) {
            summaryStrip
            controlPointPicker
            TabView(selection: Bindable(viewModel).selectedControlPointIndex) {
                ForEach(viewModel.controlPoints.indices, id: \.self) { index in
                    controlPointList(for: viewModel.controlPoints[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: viewModel.selectedControlPointIndex)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var summaryStrip: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("grades.summary.average.label")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.overallAverage.map { $0.formattedAverage } ?? String(localized: "grades.no_mark"))
                    .font(.title3.bold())
                    .foregroundStyle(viewModel.overallAverage == nil ? .secondary : .primary)
            }
        }
        .padding(.horizontal, Constants.Layout.summaryHorizontalPadding)
        .padding(.vertical, Constants.Layout.summaryVerticalPadding)
    }

    private var controlPointPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Layout.pickerSpacing) {
                ForEach(viewModel.controlPoints.indices, id: \.self) { index in
                    let point = viewModel.controlPoints[index]
                    let isSelected = viewModel.selectedControlPointIndex == index
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.selectedControlPointIndex = index
                        }
                    } label: {
                        Text(shortLabel(for: point))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(isSelected ? .white : .primary)
                            .padding(.horizontal, Constants.Layout.pillHorizontalPadding)
                            .padding(.vertical, Constants.Layout.pillVerticalPadding)
                            .background(
                                isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Constants.Layout.pickerHorizontalPadding)
            .padding(.vertical, Constants.Layout.pickerVerticalPadding)
        }
    }

    private func controlPointList(for point: GradeBookControlPoint) -> some View {
        let items = groupedSubjects(point).filter { hasContent($0.groups) }
        return List {
            Section {
                ForEach(items, id: \.name) { item in
                    SubjectCardView(subjectName: item.name, groups: item.groups)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(Constants.Layout.rowInsets)
                }
            } header: {
                HStack {
                    Text(fullLabel(for: point))
                    Spacer()
                    if let avg = point.average {
                        Text(avg.formattedAverage)
                    }
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .textCase(nil)
            }
        }
        .ignoresSafeArea(edges: .bottom) // skebob
        .background(.red)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }

    private func shortLabel(for point: GradeBookControlPoint) -> String {
        guard point.date != .distantFuture else {
            return String(localized: "grades.control_point.outside.short")
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: point.date)
    }

    private func fullLabel(for point: GradeBookControlPoint) -> String {
        guard point.date != .distantFuture else {
            return String(localized: "grades.control_point.outside")
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: point.date)
    }

    private func hasContent(_ groups: [GradeBookSubjectGroup]) -> Bool {
        groups.contains { !$0.marks.isEmpty || $0.totalOmissions > 0 }
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

// MARK: - Subject Card

private struct SubjectCardView: View {
    let subjectName: String
    let groups: [GradeBookSubjectGroup]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(subjectName)
                .font(.headline)
                .padding(Constants.Layout.cardPadding)

            Divider()
                .padding(.horizontal, Constants.Layout.cardPadding)

            VStack(alignment: .leading, spacing: Constants.Layout.cardRowSpacing) {
                ForEach(Constants.lessonTypes, id: \.abbrev) { lessonType in
                    if let group = groups.first(where: { $0.lessonTypeAbbrev == lessonType.abbrev }),
                       !group.marks.isEmpty {
                        LessonTypeRow(typeKey: lessonType.key, marks: group.marks)
                    }
                }

                let totalOmissions = groups.reduce(0) { $0 + $1.totalOmissions }
                if totalOmissions > 0 {
                    OmissionsRow(total: totalOmissions)
                }
            }
            .padding(Constants.Layout.cardPadding)
        }
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .shadow(
            color: Constants.Colors.shadowColor,
            radius: Constants.Layout.shadowRadius,
            x: 0,
            y: Constants.Layout.shadowOffsetY
        )
    }
}

private struct LessonTypeRow: View {
    let typeKey: LocalizedStringKey
    let marks: [Int]

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(typeKey)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: Constants.Layout.typeColumnWidth, alignment: .leading)
            HStack(spacing: Constants.Layout.markSpacing) {
                ForEach(marks.indices, id: \.self) { index in
                    MarkBadge(value: marks[index])
                }
            }
        }
    }
}

private struct OmissionsRow: View {
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: Constants.Icons.omission)
                .font(.subheadline)
                .foregroundStyle(.red)
            Text(String(localized: "grades.omissions \(total)"))
                .font(.subheadline)
                .foregroundStyle(.red)
        }
    }
}

private struct MarkBadge: View {
    let value: Int

    var body: some View {
        Text("\(value)")
            .font(.subheadline.weight(.semibold))
            .frame(width: Constants.Layout.markSize, height: Constants.Layout.markSize)
            .background(
                value > 0 ? Constants.Colors.goodMarkBackground : Constants.Colors.zeroMarkBackground,
                in: RoundedRectangle(cornerRadius: Constants.Layout.markCornerRadius)
            )
    }
}
