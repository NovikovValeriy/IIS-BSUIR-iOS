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
            Label("Sign In Required", systemImage: "person.fill.questionmark")
        } description: {
            Text("Sign in to access your grades, notifications, dormitory, and more.")
        } actions: {
            Button("Sign In") {
                viewModel.didTapSignIn()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Profile")
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

            Section("Academic") {
                Button("Grades") { viewModel.didTapGrades() }
                Button("Notifications") { viewModel.didTapNotifications() }
            }

            Section("Campus") {
                Button("Dormitory") { viewModel.didTapDormitory() }
                Button("Documents") { viewModel.didTapDocuments() }
                Button("Contacts") { viewModel.didTapContacts() }
            }

            Section {
                Button("Log out", role: .destructive) { viewModel.didTapLogout() }
            }
        }
        .navigationTitle("Profile")
    }
}
