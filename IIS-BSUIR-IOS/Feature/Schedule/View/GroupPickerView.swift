//
//  GroupPickerView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 13.04.26.
//

import SwiftUI

struct GroupPickerView: View {
    let groups: [StudentGroupDTO]
    let isLoading: Bool
    let onSelect: (StudentGroupDTO) -> Void

    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    private var filteredGroups: [StudentGroupDTO] {
        guard !searchText.isEmpty else { return groups }
        return groups.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("group_picker.loading")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredGroups.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List(filteredGroups, id: \.id) { group in
                        Button {
                            onSelect(group)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(group.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Text(group.specialityAbbrev)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("group_picker.title")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "group_picker.search_placeholder"
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { dismiss() }
                }
            }
        }
    }
}
