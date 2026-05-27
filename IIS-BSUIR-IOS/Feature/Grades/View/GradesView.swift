//
//  GradesView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 07.05.26.
//

import Factory
import SwiftUI

// swiftlint:disable file_length
private enum Constants {
    enum Layout {
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
        static let markSize: CGFloat = 34
        static let markCornerRadius: CGFloat = 7
        static let typeColumnWidth: CGFloat = 44
        static let lessonTypeRowSpacing: CGFloat = 8
        static let subheadlineFontHeight: CGFloat = 20
        static let omissionsRowSpacing: CGFloat = 4
        static let animationDuration: Double = 0.25
        static let popoverHorizontalPadding: CGFloat = 12
        static let popoverVerticalPadding: CGFloat = 8
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
        static let lowMarkBackground = Color.red.opacity(0.18)
        static let midMarkBackground = Color.yellow.opacity(0.28)
        static let highMarkBackground = Color.green.opacity(0.18)
        static let omissionBackground = Color.red.opacity(0.18)
    }
    enum Icons {
        static let grades = "list.number"
        static let omission = "exclamationmark.circle.fill"
    }
    enum Strings {
        static let omissionsRowLabel: LocalizedStringKey = "grades.omissions.row_label"
        static let summaryTab: LocalizedStringKey = "grades.summary.tab"
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
    @State private var viewModel: GradesViewModel
    private let title: String

    init(viewModel: GradesViewModel, title: String = String(localized: "grades.title")) {
        _viewModel = State(initialValue: viewModel)
        self.title = title
    }

    var body: some View {
        Group {
            if viewModel.gradeBook != nil {
                loadedView
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView("grades.empty.title", systemImage: Constants.Icons.grades)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var loadedView: some View {
        VStack(spacing: 0) {
            tabPicker
            TabView(selection: Bindable(viewModel).selectedTabIndex) {
                ForEach(viewModel.controlPoints.indices, id: \.self) { index in
                    controlPointList(for: viewModel.controlPoints[index])
                        .tag(index)
                }
                if !viewModel.subjectSummaries.isEmpty {
                    subjectSummaryList
                        .tag(viewModel.controlPoints.count)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: Constants.Layout.animationDuration), value: viewModel.selectedTabIndex)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Layout.pickerSpacing) {
                ForEach(viewModel.controlPoints.indices, id: \.self) { index in
                    pickerPill(label: shortLabel(for: viewModel.controlPoints[index]), tag: index)
                }
                if !viewModel.subjectSummaries.isEmpty {
                    pickerPill(label: String(localized: "grades.summary.tab"), tag: viewModel.controlPoints.count)
                }
            }
            .padding(.horizontal, Constants.Layout.pickerHorizontalPadding)
            .padding(.vertical, Constants.Layout.pickerVerticalPadding)
        }
    }

    private func pickerPill(label: String, tag: Int) -> some View {
        let isSelected = viewModel.selectedTabIndex == tag
        return Button {
            withAnimation(.easeInOut(duration: Constants.Layout.animationDuration)) {
                viewModel.selectedTabIndex = tag
            }
        } label: {
            Text(label)
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

    // MARK: - Summary tab

    private var subjectSummaryList: some View {
        List {
            Section {
                ForEach(viewModel.subjectSummaries, id: \.subjectName) { summary in
                    SubjectSummaryCardView(summary: summary)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(Constants.Layout.rowInsets)
                }
            } header: {
                HStack {
                    Text(Constants.Strings.summaryTab)
                    Spacer()
                    if let info = headerInfoText(
                        avg: viewModel.overallAverage,
                        omissionHours: viewModel.overallOmissionHours
                    ) {
                        Text(info)
                    }
                }
                .font(.callout.weight(.semibold))
                .foregroundStyle(.primary)
                .textCase(nil)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }

    // MARK: - Control point tab

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
                    if let info = headerInfoText(avg: point.average, omissionHours: point.totalOmissionHours) {
                        Text(info)
                    }
                }
                .font(.callout.weight(.semibold))
                .foregroundStyle(.primary)
                .textCase(nil)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }

    // MARK: - Helpers

    private func headerInfoText(avg: Double?, omissionHours: Int) -> String? {
        var parts: [String] = []
        if let avg { parts.append(String(localized: "grades.header.avg \(avg.formattedAverage)")) }
        if omissionHours > 0 { parts.append(String(localized: "grades.header.oms \(omissionHours)")) }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
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
        groups.contains { !$0.marks.isEmpty || !$0.omissions.isEmpty }
    }

    private func groupedSubjects(
        _ controlPoint: GradeBookControlPoint
    ) -> [(name: String, groups: [GradeBookSubjectGroup])] {
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

// MARK: - Subject Summary Card

private struct SubjectSummaryCardView: View {
    let summary: GradeBookSubjectSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(summary.subjectName)
                    .font(.headline)
                Spacer()
                if let avg = summary.overallAverage {
                    Text(avg.formattedAverage)
                        .font(.title3.bold())
                }
            }
            .padding(Constants.Layout.cardPadding)

            if !summary.lessonTypeAverages.isEmpty || summary.totalOmissionHours > 0 {
                Divider()
                    .padding(.horizontal, Constants.Layout.cardPadding)

                VStack(alignment: .leading, spacing: Constants.Layout.cardRowSpacing) {
                    ForEach(summary.lessonTypeAverages, id: \.abbrev) { typeAvg in
                        HStack {
                            Text(typeAvg.abbrev)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: Constants.Layout.typeColumnWidth, alignment: .leading)
                            Spacer()
                            Text(typeAvg.average.formattedAverage)
                                .font(.subheadline.weight(.medium))
                        }
                    }

                    if summary.totalOmissionHours > 0 {
                        HStack {
                            Text(Constants.Strings.omissionsRowLabel)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: Constants.Layout.typeColumnWidth, alignment: .leading)
                            Spacer()
                            Text(String(localized: "grades.omissions.hours \(summary.totalOmissionHours)"))
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(Constants.Layout.cardPadding)
            }
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

// MARK: - Subject Card (control point tab)

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

                let omissions = groups.flatMap { $0.omissions }
                if !omissions.isEmpty {
                    OmissionsRow(omissions: omissions)
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
    let marks: [GradeBookMark]

    var body: some View {
        HStack(alignment: .top, spacing: Constants.Layout.lessonTypeRowSpacing) {
            Text(typeKey)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: Constants.Layout.typeColumnWidth, alignment: .leading)
                .padding(.top, (Constants.Layout.markSize - Constants.Layout.subheadlineFontHeight) / 2)
            FlowLayout(spacing: Constants.Layout.markSpacing) {
                ForEach(marks.indices, id: \.self) { index in
                    MarkBadge(mark: marks[index])
                }
            }
        }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentY += rowHeight + spacing
                currentX = 0
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return CGSize(width: maxWidth, height: currentY + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                currentY += rowHeight + spacing
                currentX = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

private struct OmissionsRow: View {
    let omissions: [GradeBookOmission]

    var body: some View {
        HStack(alignment: .top, spacing: Constants.Layout.lessonTypeRowSpacing) {
            Text(Constants.Strings.omissionsRowLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: Constants.Layout.typeColumnWidth, alignment: .leading)
                .padding(.top, (Constants.Layout.markSize - Constants.Layout.subheadlineFontHeight) / 2)
            FlowLayout(spacing: Constants.Layout.markSpacing) {
                ForEach(omissions.indices, id: \.self) { index in
                    OmissionBadge(omission: omissions[index])
                }
            }
        }
    }
}

private struct OmissionBadge: View {
    let omission: GradeBookOmission

    @State private var showingDate = false

    var body: some View {
        Text("\(omission.count)")
            .font(.subheadline.weight(.semibold))
            .frame(width: Constants.Layout.markSize, height: Constants.Layout.markSize)
            .background(
                Constants.Colors.omissionBackground,
                in: RoundedRectangle(cornerRadius: Constants.Layout.markCornerRadius)
            )
            .onTapGesture { if omission.date != nil { showingDate = true } }
            .popover(isPresented: $showingDate) {
                if let date = omission.date {
                    Text(date.formatted(.dateTime.day().month().year()))
                        .font(.subheadline)
                        .padding(.horizontal, Constants.Layout.popoverHorizontalPadding)
                        .padding(.vertical, Constants.Layout.popoverVerticalPadding)
                        .presentationCompactAdaptation(.popover)
                }
            }
    }
}

private struct MarkBadge: View {
    let mark: GradeBookMark

    @State private var showingDate = false

    var body: some View {
        Text("\(mark.value)")
            .font(.subheadline.weight(.semibold))
            .frame(width: Constants.Layout.markSize, height: Constants.Layout.markSize)
            .background(badgeColor, in: RoundedRectangle(cornerRadius: Constants.Layout.markCornerRadius))
            .onTapGesture { if mark.date != nil { showingDate = true } }
            .popover(isPresented: $showingDate) {
                if let date = mark.date {
                    Text(date.formatted(.dateTime.day().month().year()))
                        .font(.subheadline)
                        .padding(.horizontal, Constants.Layout.popoverHorizontalPadding)
                        .padding(.vertical, Constants.Layout.popoverVerticalPadding)
                        .presentationCompactAdaptation(.popover)
                }
            }
    }

    private var badgeColor: Color {
        switch mark.value {
        case 0...3: return Constants.Colors.lowMarkBackground
        case 4...7: return Constants.Colors.midMarkBackground
        default:    return Constants.Colors.highMarkBackground
        }
    }
}
// swiftlint:enable file_length
