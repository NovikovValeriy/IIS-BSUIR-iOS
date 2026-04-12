//
//  HeadmanToolsFlowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct HeadmanToolsFlowView: View {
    @State private var router: HeadmanToolsRouter = Container.shared.headmanToolsRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            HeadmanToolsView()
                .navigationDestination(for: HeadmanToolsDestination.self) { destination in
                    switch destination {
                    case .omissionsByDate(let date):
                        Text("Omissions: \(date.formatted(date: .abbreviated, time: .omitted))")
                            .navigationTitle("Omissions")
                    case .markSheet(let id):
                        Text("Mark sheet: \(id)")
                            .navigationTitle("Mark Sheet")
                    }
                }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            switch sheet {
            case .datePicker:
                Text("Date picker — coming soon")
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
