//
//  RatingsView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 24.05.26.
//

import SwiftUI
import Factory

private enum Constants {
    enum Layout {
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
        static let rankMinWidth: CGFloat = 44
        static let averageMinWidth: CGFloat = 52
        static let omissionsMinWidth: CGFloat = 40
        static let cardHSpacing: CGFloat = 8
        static let pickerHPadding: CGFloat = 14
        static let pickerVPadding: CGFloat = 11
        static let pickerCornerRadius: CGFloat = 10
        static let pickerAreaPadding: CGFloat = 16
        static let pickerSpacing: CGFloat = 8
        static let fadeHeight: CGFloat = 10
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let pickerActive = Color(.secondarySystemGroupedBackground)
        static let pickerDisabled = Color(.tertiarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
        static let highAverage = Color.green.opacity(0.18)
        static let midAverage = Color.yellow.opacity(0.28)
        static let lowAverage = Color.red.opacity(0.18)
    }
    enum Icons {
        static let empty = "chart.bar"
        static let chevron = "chevron.up.chevron.down"
        static let omissions = "exclamationmark.circle.fill"
    }
}

struct RatingsView: View {
    @State private var viewModel: RatingsViewModel = Container.shared.ratingsViewModel()
    @State private var isRefreshing = false

    var body: some View {
        VStack(spacing: 0) {
            pickerArea

            if viewModel.selectedCourse != nil {
                if viewModel.students.isEmpty && viewModel.isLoadingStudents && !isRefreshing {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                } else {
                    studentList
                }
            } else {
                Spacer()
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("ratings.title")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .onChange(of: viewModel.selectedFacultyId) { _, newId in
            Task { await viewModel.didSelectFaculty(newId) }
        }
        .onChange(of: viewModel.selectedSpecialityId) { _, newId in
            Task { await viewModel.didSelectSpeciality(newId) }
        }
        .onChange(of: viewModel.selectedCourse) { _, newCourse in
            Task { await viewModel.didSelectCourse(newCourse) }
        }
    }

    private var pickerArea: some View {
        VStack(spacing: Constants.Layout.pickerSpacing) {
            RatingPickerView(
                placeholder: "ratings.picker.select",
                selectedLabel: viewModel.faculties.first(where: { $0.id == viewModel.selectedFacultyId })?.name,
                isLoading: viewModel.isLoadingFaculties,
                isDisabled: false
            ) {
                Picker("", selection: Bindable(viewModel).selectedFacultyId) {
                    Text("ratings.picker.select").tag(Int?.none)
                    ForEach(viewModel.faculties) { faculty in
                        Text(faculty.name).tag(Optional(faculty.id))
                    }
                }
                .labelsHidden()
            }

            RatingPickerView(
                placeholder: "ratings.picker.select",
                selectedLabel: viewModel.specialities.first(where: { $0.id == viewModel.selectedSpecialityId })?.name,
                isLoading: viewModel.isLoadingSpecialities,
                isDisabled: viewModel.selectedFacultyId == nil
            ) {
                Picker("", selection: Bindable(viewModel).selectedSpecialityId) {
                    Text("ratings.picker.select").tag(Int?.none)
                    ForEach(viewModel.specialities) { spec in
                        Text(spec.name).tag(Optional(spec.id))
                    }
                }
                .labelsHidden()
            }

            RatingPickerView(
                placeholder: "ratings.picker.select",
                selectedLabel: viewModel.selectedCourse.map {
                    String(localized: "ratings.picker.course_value \($0)")
                },
                isLoading: viewModel.isLoadingCourses,
                isDisabled: viewModel.selectedSpecialityId == nil
            ) {
                Picker("", selection: Bindable(viewModel).selectedCourse) {
                    Text("ratings.picker.select").tag(Int?.none)
                    ForEach(viewModel.courses, id: \.self) { course in
                        Text("ratings.picker.course_value \(course)").tag(Optional(course))
                    }
                }
                .labelsHidden()
            }
        }
        .padding(Constants.Layout.pickerAreaPadding)
    }

    private var studentList: some View {
        List {
            if !viewModel.students.isEmpty {
                ForEach(Array(viewModel.students.enumerated()), id: \.element.id) { index, student in
                    Button { viewModel.didTapStudent(student) } label: {
                        StudentRatingRowView(rank: index + 1, student: student)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(Constants.Layout.rowInsets)
                }
            } else if !viewModel.isLoadingStudents {
                ContentUnavailableView("ratings.empty.title", systemImage: Constants.Icons.empty)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            isRefreshing = true
            await viewModel.refresh()
            isRefreshing = false
        }
    }
}

private struct RatingPickerView<Content: View>: View {
    let placeholder: LocalizedStringKey
    let selectedLabel: String?
    let isLoading: Bool
    let isDisabled: Bool
    @ViewBuilder let content: Content

    init(
        placeholder: LocalizedStringKey,
        selectedLabel: String?,
        isLoading: Bool,
        isDisabled: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.placeholder = placeholder
        self.selectedLabel = selectedLabel
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.content = content()
    }

    private var isSelected: Bool { selectedLabel != nil }

    private var background: Color {
        isDisabled ? Constants.Colors.pickerDisabled : Constants.Colors.pickerActive
    }

    private var foregroundColor: Color {
        if isDisabled { return Color(.tertiaryLabel) }
        return isSelected ? Color(.label) : Color(.secondaryLabel)
    }

    var body: some View {
        Menu {
            content
        } label: {
            HStack {
                Group {
                    if let label = selectedLabel {
                        Text(label)
                    } else {
                        Text(placeholder)
                    }
                }
                .font(.body)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.75)
                } else {
                    Image(systemName: Constants.Icons.chevron)
                        .font(.caption.weight(.medium))
                }
            }
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, Constants.Layout.pickerHPadding)
            .padding(.vertical, Constants.Layout.pickerVPadding)
            .background(background, in: RoundedRectangle(cornerRadius: Constants.Layout.pickerCornerRadius))
            .shadow(
                color: Constants.Colors.shadowColor,
                radius: Constants.Layout.shadowRadius,
                x: 0,
                y: Constants.Layout.shadowOffsetY
            )
            .contentShape(RoundedRectangle(cornerRadius: Constants.Layout.pickerCornerRadius))
        }
        .disabled(isLoading || isDisabled)
    }
}

private struct StudentRatingRowView: View {
    let rank: Int
    let student: StudentRating

    var body: some View {
        HStack(spacing: Constants.Layout.cardHSpacing) {
            Text("#\(rank)")
                .font(.callout.weight(.bold))
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .lineLimit(1)
                .frame(minWidth: Constants.Layout.rankMinWidth, alignment: .leading)

            Text(student.cardNumber)
                .font(.body.weight(.medium))
                .lineLimit(1)

            Spacer()

            Text(student.average.formattedAverage)
                .font(.body.weight(.medium))
                .monospacedDigit()
                .frame(minWidth: Constants.Layout.averageMinWidth)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(averageColor(student.average), in: RoundedRectangle(cornerRadius: 8))

            Text("\(student.omissionHours)")
                .font(.body.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(student.omissionHours > 0 ? .red : .secondary)
                .frame(minWidth: Constants.Layout.omissionsMinWidth)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    student.omissionHours > 0 ? Color.red.opacity(0.18) : Color.secondary.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 8)
                )
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

    private func averageColor(_ avg: Double) -> Color {
        switch avg {
        case 7...: return Constants.Colors.highAverage
        case 4..<7: return Constants.Colors.midAverage
        default: return Constants.Colors.lowAverage
        }
    }
}

private extension Double {
    var formattedAverage: String {
        var result = String(format: "%.2f", self)
        while result.hasSuffix("0") { result.removeLast() }
        if result.hasSuffix(".") { result.removeLast() }
        return result
    }
}
