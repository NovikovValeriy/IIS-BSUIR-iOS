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
        static let noClasses = "calendar"
        static let error = "exclamationmark.triangle"
        static let modeWeekly = "list.bullet"
        static let modeTimeline = "calendar.badge.clock"
        static let modeExams = "graduationcap"
        static let subgroupAll = "person.2"
        static let subgroupFirst = "1.circle"
        static let subgroupSecond = "2.circle"
    }
}

/// Core schedule content view shared by both schedule screens.
/// Renders the lesson list, loading/error states, and the display-mode and
/// subgroup-filter toolbar buttons. Screen-specific empty states and toolbar
/// items are supplied by the calling view.
struct ScheduleView<EmptyState: View>: View {
    @Bindable var viewModel: ScheduleViewModel
    @ViewBuilder let emptyState: () -> EmptyState

    var body: some View {
        ZStack {
            if viewModel.isLoadingSchedule {
                ProgressView("schedule.loading")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.selectedSubject == nil {
                emptyState()
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
            } else if viewModel.displayMode == .exams {

                TimelineScheduleView(
                    viewModel: viewModel,
                    days: viewModel.examsDays,
                    isExhausted: true,
                    onLoadMore: nil,
                    onRefresh: { await viewModel.didPullToRefresh() },
                    emptyState: {
                        ContentUnavailableView(
                            "schedule.no_exams.title",
                            systemImage: Constants.Icons.modeExams,
                            description: Text(
                                "schedule.no_exams.description \(viewModel.selectedSubject?.displayName ?? "")"
                            )
                        )
                    }
                )
            } else {
                TimelineScheduleView(
                    viewModel: viewModel,
                    days: viewModel.timelineDays,
                    isExhausted: viewModel.timelineExhausted,
                    onLoadMore: {
                        viewModel.loadMoreTimelineDays()
                    },
                    onRefresh: { await viewModel.didPullToRefresh() },
                    emptyState: {
                        ContentUnavailableView(
                            "schedule.no_classes.title",
                            systemImage: Constants.Icons.noClasses,
                            description: Text(
                                "schedule.no_classes.description \(viewModel.selectedSubject?.displayName ?? "")"
                            )
                        )
                    }
                )
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .toolbar {
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
            switch newMode {
            case .timeline:
                viewModel.ensureTimelineGenerated()
            case .exams:
                viewModel.ensureExamsGenerated()
            case .weekly:
                break
            }
        }
        .overlay(alignment: .bottom) {
            if viewModel.isOfflineFallback {
                OfflineBannerView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isOfflineFallback)
            }
        }
    }

    // MARK: - Subviews

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("common.error.title", systemImage: Constants.Icons.error)
        } description: {
            Text(message)
        } actions: {
            Button("schedule.retry") {
                viewModel.didTapRetry()
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
        .refreshable {
            await viewModel.didPullToRefresh()
        }
    }

    private var subgroupFilterPicker: some View {
        Menu {
            Picker("schedule.subgroup.label", selection: $viewModel.subgroupFilter) {
                Label("schedule.subgroup.all", systemImage: Constants.Icons.subgroupAll)
                    .tag(SubgroupFilter.all)
                Label("schedule.subgroup.first", systemImage: Constants.Icons.subgroupFirst)
                    .tag(SubgroupFilter.first)
                Label("schedule.subgroup.second", systemImage: Constants.Icons.subgroupSecond)
                    .tag(SubgroupFilter.second)
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
                Label("schedule.mode.exams", systemImage: Constants.Icons.modeExams)
                    .tag(ScheduleDisplayMode.exams)
            }
        } label: {
            Image(systemName: displayModeIcon)
        }
    }

    private var displayModeIcon: String {
        switch viewModel.displayMode {
        case .timeline: return Constants.Icons.modeTimeline
        case .weekly: return Constants.Icons.modeWeekly
        case .exams: return Constants.Icons.modeExams
        }
    }
}
