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
                        RatingsView()
                    case .subjects:
                        SubjectsView()
                    case .departments:
                        DepartmentsView()
                    case .departmentEmployees(let department):
                        DepartmentEmployeesView(department: department)
                    case .studentGrades(let cardNumber):
                        let adapter = StudentGradesAdapter(
                            cardNumber: cardNumber,
                            service: Container.shared.ratingsService()
                        )
                        GradesView(
                            viewModel: GradesViewModel(gradesService: adapter),
                            title: String(localized: "ratings.student.grades_title \(cardNumber)")
                        )
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
