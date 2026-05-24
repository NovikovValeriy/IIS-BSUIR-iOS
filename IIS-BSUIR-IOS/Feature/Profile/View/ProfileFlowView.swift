//
//  ProfileFlowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct ProfileFlowView: View {
    @State private var router: ProfileRouter = Container.shared.profileRouter()
    @State private var viewModel: ProfileViewModel = Container.shared.profileViewModel()

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileView()
                .navigationDestination(for: ProfileDestination.self) { destination in
                    switch destination {
                    case .markBook:
                        MarkBookView()
                    case .grades:
                        GradesView(viewModel: Container.shared.gradesViewModel())
                    case .omissions:
                        Text("profile.omissions.title")
                            .navigationTitle("profile.omissions.title")
                    case .certificates:
                        Text("profile.certificates.title")
                            .navigationTitle("profile.certificates.title")
                    case .groupInfo:
                        Text("profile.group_info.title")
                            .navigationTitle("profile.group_info.title")
                    case .library:
                        Text("profile.library.title")
                            .navigationTitle("profile.library.title")
                    case .announcements:
                        Text("profile.announcements.title")
                            .navigationTitle("profile.announcements.title")
                    case .dormitory:
                        Text("profile.dormitory.title")
                            .navigationTitle("profile.dormitory.title")
                    case .penalties:
                        Text("profile.penalties.title")
                            .navigationTitle("profile.penalties.title")
                    case .activity:
                        Text("profile.activity.title")
                            .navigationTitle("profile.activity.title")
                    }
                }
        }
        .alert(
            "profile.logout_confirmation.title",
            isPresented: Binding(
                get: { router.confirmationDialog != nil },
                set: { if !$0 { router.confirmationDialog = nil } }
            )
        ) {
            Button("profile.logout_confirmation.button", role: .destructive) {
                viewModel.confirmLogout()
            }
            Button("common.cancel", role: .cancel) {}
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("common.ok"))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .popToRoot(for: .profile))) { _ in
            router.popToRoot()
        }
    }
}
