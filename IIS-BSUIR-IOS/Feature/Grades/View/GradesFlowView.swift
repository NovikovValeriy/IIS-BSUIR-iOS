//
//  GradesFlowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct GradesFlowView: View {
    @State private var router: GradesRouter = Container.shared.gradesRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            GradesView()
                .navigationDestination(for: GradesDestination.self) { destination in
                    switch destination {
                    case .gradeBookDetail(let subjectName):
                        Text("Grade book: \(subjectName)")
                            .navigationTitle(subjectName)
                    case .omissions:
                        Text("Omissions")
                            .navigationTitle("Omissions")
                    }
                }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            switch sheet {
            case .semesterPicker:
                Text("Semester picker — coming soon")
                    .presentationDetents([.height(300)])
            }
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
