//
//  ScheduleView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI

private enum Constants {
    enum Layout {
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
    }
    enum Icons {
        static let group = "magnifyingglass"
        static let noClasses = "calendar"
        static let error = "exclamationmark.triangle"
        static let modeWeekly = "list.bullet"
        static let modeTimeline = "calendar.badge.clock"
        static let subgroupAll = "person.2"
        static let subgroupFirst = "1.circle"
        static let subgroupSecond = "2.circle"
        static let pin = "bookmark"
        static let pinFill = "bookmark.fill"
        static let noPinned = "bookmark.slash"
    }
}

struct ScheduleView: View {
    @Bindable var viewModel: ScheduleViewModel

    var body: some View {
        Group {
            if viewModel.isLoadingSchedule {
                ProgressView("schedule.loading")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.selectedSubject == nil {
                if viewModel.canChangeSubject { noSubjectView } else { noPinnedSubjectView }
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else if viewModel.displayMode == .weekly && viewModel.lessons.isEmpty {
                ContentUnavailableView(
                    "schedule.no_classes.title",
                    systemImage: Constants.Icons.noClasses,
                    description: Text("schedule.no_classes.description \(viewModel.selectedSubject?.displayName ?? "")")
                )
            } else if viewModel.displayMode == .weekly {
                weeklyScheduleList
            } else {
                TimelineScheduleView(viewModel: viewModel)
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .toolbar {
            if viewModel.canChangeSubject {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.didTapSelectGroup()
                    } label: {
                        Image(systemName: Constants.Icons.group)
                    }
                }
                if viewModel.selectedSubject != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.didTapPin()
                        } label: {
                            Image(systemName: viewModel.isPinned ? Constants.Icons.pinFill : Constants.Icons.pin)
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                subgroupFilterPicker
            }
            ToolbarItem(placement: .topBarTrailing) {
                displayModePicker
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onChange(of: viewModel.displayMode) { _, newMode in
            if newMode == .timeline {
                viewModel.ensureTimelineGenerated()
            }
        }
    }

    // MARK: - Subviews

    private var noSubjectView: some View {
        ContentUnavailableView {
            Label("schedule.no_subject.title", systemImage: Constants.Icons.group)
        } description: {
            Text("schedule.no_subject.description")
        } actions: {
            Button("schedule.select_subject.action") {
                viewModel.didTapSelectGroup()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var noPinnedSubjectView: some View {
        ContentUnavailableView {
            Label("schedule.pinned.empty.title", systemImage: Constants.Icons.noPinned)
        } description: {
            Text("schedule.pinned.empty.description")
        }
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("common.error.title", systemImage: Constants.Icons.error)
        } description: {
            Text(message)
        } actions: {
            Button("schedule.retry") {
                viewModel.didTapSelectGroup()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var weeklyScheduleList: some View {
        List {
            ForEach(viewModel.weekdayOrder, id: \.self) { weekday in
                if let dayLessons = viewModel.lessons[weekday] {
                    Section(weekday) {
                        ForEach(dayLessons, id: \.self) { lesson in
                            Button {
                                viewModel.didTapLesson(lesson)
                            } label: {
                                LessonRowView(lesson: lesson, showGroups: viewModel.showGroupsInRow)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(Constants.Layout.rowInsets)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }

    private var subgroupFilterPicker: some View {
        Menu {
            Picker("schedule.subgroup.label", selection: $viewModel.subgroupFilter) {
                Text("schedule.subgroup.all").tag(SubgroupFilter.all)
                Text("schedule.subgroup.first").tag(SubgroupFilter.first)
                Text("schedule.subgroup.second").tag(SubgroupFilter.second)
            }
        } label: {
            Image(systemName: subgroupFilterIcon)
        }
    }

    private var subgroupFilterIcon: String {
        switch viewModel.subgroupFilter {
        case .all: return Constants.Icons.subgroupAll
        case .first: return Constants.Icons.subgroupFirst
        case .second: return Constants.Icons.subgroupSecond
        }
    }

    private var displayModePicker: some View {
        Menu {
            Picker("schedule.mode.label", selection: $viewModel.displayMode) {
                Label("schedule.mode.timeline", systemImage: Constants.Icons.modeTimeline)
                    .tag(ScheduleDisplayMode.timeline)
                Label("schedule.mode.weekly", systemImage: Constants.Icons.modeWeekly)
                    .tag(ScheduleDisplayMode.weekly)
            }
        } label: {
            Image(
                systemName: viewModel.displayMode == .weekly
                ? Constants.Icons.modeWeekly
                : Constants.Icons.modeTimeline
            )
        }
    }
}
