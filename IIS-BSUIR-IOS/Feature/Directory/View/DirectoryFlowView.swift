//
//  DirectoryFlowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 24.05.26.
//

import SwiftUI
import Factory

struct DirectoryFlowView: View {
    @State private var router: DirectoryRouter = Container.shared.directoryRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            DirectoryView()
                .navigationDestination(for: DirectoryDestination.self) { destination in
                    switch destination {
                    case .ratings:
                        Text("directory.ratings.title")
                            .navigationTitle("directory.ratings.title")
                    case .subjects:
                        Text("directory.subjects.title")
                            .navigationTitle("directory.subjects.title")
                    case .departments:
                        Text("directory.departments.title")
                            .navigationTitle("directory.departments.title")
                    }
                }
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("common.ok"))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .popToRoot(for: .directory))) { _ in
            router.popToRoot()
        }
    }
}
