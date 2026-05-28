import SwiftUI
import Factory

struct AppearanceView: View {
    @State private var themeService: AppThemeService = Container.shared.appThemeService()

    private var schemeBinding: Binding<AppColorScheme> {
        Binding(
            get: { themeService.current },
            set: { themeService.set($0) }
        )
    }

    var body: some View {
        Form {
            Section("settings.appearance.theme".localized()) {
                Picker("settings.appearance.theme".localized(), selection: schemeBinding) {
                    ForEach(AppColorScheme.allCases, id: \.self) { scheme in
                        Text(scheme.title).tag(scheme)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .navigationTitle("settings.appearance.title".localized())
        .navigationBarTitleDisplayMode(.inline)
    }
}
