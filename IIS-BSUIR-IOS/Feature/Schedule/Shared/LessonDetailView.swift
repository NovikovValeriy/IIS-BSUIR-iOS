//
//  LessonDetailView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

private enum Constants {
    enum Layout {
        static let itemSpacing: CGFloat = 4
        static let itemPaddingVertical: CGFloat = 2
    }
    enum Icons {
        static let chevron = "chevron.right"
    }
    static let minutesBeforeOptions = [5, 10, 15, 30, 60]
}

struct LessonDetailView: View {
    let lesson: Lesson
    let weekday: String?
    let router: ScheduleRouter

    @State private var notificationsViewModel: LessonNotificationViewModel?

    init(lesson: Lesson, weekday: String?, router: ScheduleRouter) {
        self.lesson = lesson
        self.weekday = weekday
        self.router = router
        if let weekday, lesson.dateLesson == nil, !lesson.announcement {
            _notificationsViewModel = State(initialValue: LessonNotificationViewModel(
                lesson: lesson,
                weekday: weekday,
                notificationService: Container.shared.notificationService()
            ))
        }
    }

    var body: some View {
        List {
            subjectSection
            if let note = lesson.note, !note.isEmpty {
                noteSection(note)
            }
            timeSection
            if !lesson.auditories.isEmpty {
                roomsSection(lesson.auditories)
            }
            if !lesson.teachers.isEmpty {
                teachersSection(lesson.teachers)
            }
            if !lesson.groups.isEmpty {
                groupsSection(lesson.groups)
            }
            if let weeks = lesson.weekNumber, !weeks.isEmpty {
                weeksSection(weeks)
            }
            if let viewModel = notificationsViewModel {
                notificationSection(viewModel)
            }
        }
        .navigationTitle(lesson.subjectFullName ?? lesson.subject ?? "lesson.detail.default_title".localized())
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await notificationsViewModel?.load()
        }
        .alert(
            "notifications.permission_denied.title",
            isPresented: Binding(
                get: { notificationsViewModel?.permissionDenied == true },
                set: { if !$0 { notificationsViewModel?.dismissPermissionDenied() } }
            )
        ) {
            Button("common.ok".localized(), role: .cancel) {}
        } message: {
            Text("notifications.permission_denied".localized())
        }
    }

    private var subjectSection: some View {
        Section {
            if !lesson.announcement {
                LabeledContent("lesson.detail.subject".localized(), value: lesson.subjectFullName ?? lesson.subject ?? "—")
            }
            if let type = lesson.lessonTypeAbbrev {
                LabeledContent("lesson.detail.type".localized(), value: type)
            }
            if lesson.numSubgroup != 0 {
                LabeledContent("lesson.detail.subgroup".localized(), value: "\(lesson.numSubgroup)")
            }
            if lesson.announcement {
                LabeledContent("lesson.detail.kind".localized(), value: "lesson.detail.announcement".localized())
            }
        }
    }

    private var timeSection: some View {
        Section("lesson.detail.time".localized()) {
            LabeledContent("lesson.detail.start".localized(), value: lesson.startTime)
            LabeledContent("lesson.detail.end".localized(), value: lesson.endTime)
            if let date = lesson.dateLesson {
                LabeledContent("lesson.detail.date".localized(), value: date)
            }
            if let start = lesson.startLessonDate, let end = lesson.endLessonDate {
                LabeledContent("lesson.detail.period".localized(), value: "\(start) – \(end)")
            }
        }
    }

    private func roomsSection(_ rooms: [String]) -> some View {
        Section("lesson.detail.classrooms".localized()) {
            ForEach(rooms, id: \.self) { room in
                Text(room)
            }
        }
    }

    private func teachersSection(_ teachers: [Teacher]) -> some View {
        Section((teachers.count == 1 ? "lesson.detail.teacher" : "lesson.detail.teachers").localized()) {
            ForEach(teachers) { teacher in
                Button {
                    router.push(.employeeSchedule(teacher))
                } label: {
                    teacherRow(teacher)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func teacherRow(_ teacher: Teacher) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.Layout.itemSpacing) {
                Text(teacher.fullName)
                    .font(.body)
                    .foregroundStyle(.primary)
                if let rank = teacher.rank, !rank.isEmpty {
                    Text(rank)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let degree = teacher.degree, !degree.isEmpty {
                    Text(degree)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let email = teacher.email, !email.isEmpty {
                    Text(email)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: Constants.Icons.chevron)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .padding(.vertical, Constants.Layout.itemPaddingVertical)
    }

    private func groupsSection(_ groups: [LessonGroup]) -> some View {
        Section((groups.count == 1 ? "lesson.detail.group" : "lesson.detail.groups").localized()) {
            ForEach(groups, id: \.name) { group in
                Button {
                    router.push(.groupSchedule(group.name))
                } label: {
                    groupRow(group)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func groupRow(_ group: LessonGroup) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.Layout.itemSpacing) {
                Text(group.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                if let speciality = group.specialityName, !speciality.isEmpty {
                    Text(speciality)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let count = group.numberOfStudents {
                    Text(String(format: "lesson.detail.students_count %lld".localized(), count))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: Constants.Icons.chevron)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .padding(.vertical, Constants.Layout.itemPaddingVertical)
    }

    private func weeksSection(_ weeks: [Int]) -> some View {
        Section("lesson.detail.weeks".localized()) {
            Text(weeks.sorted().map { "\($0)" }.joined(separator: ", "))
                .foregroundStyle(.secondary)
        }
    }

    private func noteSection(_ note: String) -> some View {
        Section("lesson.detail.note".localized()) {
            Text(note)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func notificationSection(_ viewModel: LessonNotificationViewModel) -> some View {
        Section("lesson.detail.notification".localized()) {
            Toggle(
                "lesson.detail.notification.enabled".localized(),
                isOn: Binding(
                    get: { viewModel.isEnabled },
                    set: { _ in Task { await viewModel.toggle() } }
                )
            )
            .disabled(viewModel.isLoading)

            if viewModel.isEnabled {
                Picker("lesson.detail.notification.mode".localized(), selection: Binding(
                    get: { viewModel.selectedMode },
                    set: { newMode in
                        viewModel.selectedMode = newMode
                        Task { await viewModel.reschedule() }
                    }
                )) {
                    ForEach(NotificationMode.allCases) { mode in
                        Text(mode.localizedTitle).tag(mode)
                    }
                }

                Picker("lesson.detail.notification.before".localized(), selection: Binding(
                    get: { viewModel.minutesBefore },
                    set: { newMinutes in
                        viewModel.minutesBefore = newMinutes
                        Task { await viewModel.reschedule() }
                    }
                )) {
                    ForEach(Constants.minutesBeforeOptions, id: \.self) { minutes in
                        Text(String(format: "lesson.detail.notification.minutes %lld".localized(), minutes)).tag(minutes)
                    }
                }
            }
        }
    }
}
