//
//  ScheduleSubjectPickerView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 13.04.26.
//

import SwiftUI

private enum Constants {
    enum Layout {
        static let itemSpacing: CGFloat = 2
        static let segmentPadding: CGFloat = 16
    }
}

private enum SubjectPickerTab: CaseIterable {
    case groups
    case teachers
}

struct ScheduleSubjectPickerView: View {
    let groups: [GroupModel]
    let isLoadingGroups: Bool
    let teachers: [Teacher]
    let isLoadingTeachers: Bool
    let onSelect: (ScheduleSubject) -> Void
    let onTeacherTabAppear: () -> Void

    @State private var selectedTab: SubjectPickerTab = .groups
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    private var filteredGroups: [GroupModel] {
        guard !searchText.isEmpty else { return groups }
        return groups.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var filteredTeachers: [Teacher] {
        guard !searchText.isEmpty else { return teachers }
        return teachers.filter {
            $0.lastName.localizedCaseInsensitiveContains(searchText) ||
            $0.firstName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var searchPrompt: String {
        selectedTab == .groups ? "subject_picker.search_groups".localized() : "subject_picker.search_teachers".localized()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("subject_picker.tab.label".localized(), selection: $selectedTab) {
                    Text("subject_picker.tab.groups".localized()).tag(SubjectPickerTab.groups)
                    Text("subject_picker.tab.teachers".localized()).tag(SubjectPickerTab.teachers)
                }
                .pickerStyle(.segmented)
                .padding(Constants.Layout.segmentPadding)

                switch selectedTab {
                case .groups:
                    groupsContent
                case .teachers:
                    teachersContent
                }
            }
            .navigationTitle("subject_picker.title".localized())
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: searchPrompt
            )
            .onChange(of: selectedTab) { _, newTab in
                searchText = ""
                if newTab == .teachers { onTeacherTabAppear() }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localized()) { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private var groupsContent: some View {
        if isLoadingGroups {
            ProgressView("subject_picker.loading_groups".localized())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if filteredGroups.isEmpty {
            ContentUnavailableView.search(text: searchText)
        } else {
            List(filteredGroups) { group in
                Button {
                    onSelect(.group(group))
                } label: {
                    subjectRow(primary: group.name, secondary: group.specialityAbbrev)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var teachersContent: some View {
        if isLoadingTeachers {
            ProgressView("subject_picker.loading_teachers".localized())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if filteredTeachers.isEmpty {
            ContentUnavailableView.search(text: searchText)
        } else {
            List(filteredTeachers) { teacher in
                Button {
                    onSelect(.teacher(teacher))
                } label: {
                    subjectRow(primary: teacher.fullName, secondary: teacher.rank)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func subjectRow(primary: String, secondary: String?) -> some View {
        VStack(alignment: .leading, spacing: Constants.Layout.itemSpacing) {
            Text(primary)
                .font(.body)
                .foregroundStyle(.primary)
            if let secondary {
                Text(secondary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
