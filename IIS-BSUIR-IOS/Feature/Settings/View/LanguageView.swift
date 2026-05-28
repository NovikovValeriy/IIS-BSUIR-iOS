import SwiftUI
import Factory

struct LanguageView: View {
    @State private var languageService: AppLanguageService = Container.shared.appLanguageService()

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { languageService.current },
            set: { languageService.set($0) }
        )
    }

    var body: some View {
        Form {
            Section {
                Picker("settings.language.title".localized(), selection: languageBinding) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.title).tag(lang)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .navigationTitle("settings.language.title".localized())
        .navigationBarTitleDisplayMode(.inline)
    }
}
