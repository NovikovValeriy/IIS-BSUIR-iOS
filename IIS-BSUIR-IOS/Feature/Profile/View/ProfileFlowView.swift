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
                    case .certificates:
                        DocumentsView()
                    case .groupInfo:
                        GroupInfoView()
                    case .announcements:
                        AnnouncementsView()
                    case .dormitory:
                        DormitoryView()
                    case .penalties:
                        PenaltiesView()
                    case .activity:
                        ActivityView()
                    case .library:
                        LibraryView()
                    case .omissions:
                        OmissionsView()
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
            Button("profile.logout_confirmation.button".localized(), role: .destructive) {
                viewModel.confirmLogout()
            }
            Button("common.cancel".localized(), role: .cancel) {}
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("common.ok".localized()))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .popToRoot(for: .profile))) { _ in
            router.popToRoot()
        }
    }
}
