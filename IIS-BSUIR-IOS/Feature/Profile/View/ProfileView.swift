//
//  ProfileView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel = Container.shared.profileViewModel()

    var body: some View {
        if viewModel.isAuthenticated {
            authenticatedView
        } else {
            unauthenticatedView
        }
    }

    private var unauthenticatedView: some View {
        ContentUnavailableView {
            Label("profile.not_authenticated.title", systemImage: "person.fill.questionmark")
        } description: {
            Text("profile.not_authenticated.description")
        } actions: {
            Button("profile.sign_in") {
                viewModel.didTapSignIn()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("profile.title")
    }

    private var authenticatedView: some View {
        List {
            if let user = viewModel.authenticatedUser {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.fio)
                            .font(.headline)
                        Text(user.group)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("profile.academic_section") {
                Button("profile.grades") { viewModel.didTapGrades() }
                Button("profile.notifications") { viewModel.didTapNotifications() }
            }

            Section("profile.campus_section") {
                Button("profile.dormitory") { viewModel.didTapDormitory() }
                Button("profile.documents") { viewModel.didTapDocuments() }
                Button("profile.contacts") { viewModel.didTapContacts() }
            }

            Section {
                Button("profile.logout", role: .destructive) { viewModel.didTapLogout() }
            }
        }
        .navigationTitle("profile.title")
    }
}
