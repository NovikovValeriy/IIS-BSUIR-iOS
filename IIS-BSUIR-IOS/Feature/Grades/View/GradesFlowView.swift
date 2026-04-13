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
                        Text("grades.grade_book_detail \(subjectName)")
                            .navigationTitle(subjectName)
                    case .omissions:
                        Text("grades.omissions")
                            .navigationTitle("grades.omissions")
                    }
                }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            switch sheet {
            case .semesterPicker:
                Text("grades.semester_picker.coming_soon")
                    .presentationDetents([.height(300)])
            }
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("common.ok"))
            )
        }
    }
}
