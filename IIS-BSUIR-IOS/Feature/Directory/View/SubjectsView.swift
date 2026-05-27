//
//  SubjectsView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 26.05.26.
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
        static let cardHSpacing: CGFloat = 8
        static let pickerHPadding: CGFloat = 14
        static let pickerVPadding: CGFloat = 11
        static let pickerCornerRadius: CGFloat = 10
        static let pickerAreaPadding: CGFloat = 16
        static let pickerSpacing: CGFloat = 8
        static let hoursBadgeHPadding: CGFloat = 8
        static let hoursBadgeVPadding: CGFloat = 5
        static let hoursBadgeCornerRadius: CGFloat = 8
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let pickerActive = Color(.secondarySystemGroupedBackground)
        static let pickerDisabled = Color(.tertiarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
        static let hoursBadgeBackground = Color.accentColor.opacity(0.12)
    }
    enum Icons {
        static let empty = "books.vertical"
        static let chevron = "chevron.up.chevron.down"
    }
}

struct SubjectsView: View {
    @State private var viewModel: SubjectsViewModel = Container.shared.subjectsViewModel()
    @State private var isRefreshing = false

    var body: some View {
        VStack(spacing: 0) {
            pickerArea

            if viewModel.selectedCourse != nil {
                if viewModel.disciplines.isEmpty && viewModel.isLoadingDisciplines && !isRefreshing {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                } else {
                    disciplineList
                }
            } else {
                Spacer()
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("directory.subjects.title")
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
        .onChange(of: viewModel.selectedSemester) { _, newTerm in
            Task { await viewModel.didSelectSemester(newTerm) }
        }
    }

    private var pickerArea: some View {
        VStack(spacing: Constants.Layout.pickerSpacing) {
            SubjectPickerView(
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

            SubjectPickerView(
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

            SubjectPickerView(
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

            SubjectPickerView(
                placeholder: "ratings.picker.select",
                selectedLabel: viewModel.selectedSemester.map {
                    String(localized: "subjects.picker.semester_value \($0)")
                },
                isLoading: false,
                isDisabled: viewModel.selectedCourse == nil
            ) {
                Picker("", selection: Bindable(viewModel).selectedSemester) {
                    Text("ratings.picker.select").tag(Int?.none)
                    ForEach(viewModel.semesters, id: \.self) { semester in
                        Text("subjects.picker.semester_value \(semester)").tag(Optional(semester))
                    }
                }
                .labelsHidden()
            }
        }
        .padding(Constants.Layout.pickerAreaPadding)
    }

    private var disciplineList: some View {
        List {
            if !viewModel.disciplines.isEmpty {
                ForEach(Array(viewModel.disciplines.enumerated()), id: \.element.id) { index, discipline in
                    DisciplineRowView(rank: index + 1, discipline: discipline)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(Constants.Layout.rowInsets)
                }
            } else if !viewModel.isLoadingDisciplines {
                ContentUnavailableView("subjects.empty.title", systemImage: Constants.Icons.empty)
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

private struct SubjectPickerView<Content: View>: View {
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

private struct DisciplineRowView: View {
    let rank: Int
    let discipline: Discipline

    var body: some View {
        HStack(alignment: .top, spacing: Constants.Layout.cardHSpacing) {
            Text("#\(rank)")
                .font(.callout.weight(.bold))
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(minWidth: Constants.Layout.rankMinWidth, alignment: .leading)

            Text(discipline.name)
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("subjects.hours \(discipline.hours)")
                .font(.callout.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, Constants.Layout.hoursBadgeHPadding)
                .padding(.vertical, Constants.Layout.hoursBadgeVPadding)
                .background(
                    Constants.Colors.hoursBadgeBackground,
                    in: RoundedRectangle(
                        cornerRadius: Constants.Layout.hoursBadgeCornerRadius
                    )
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
}
