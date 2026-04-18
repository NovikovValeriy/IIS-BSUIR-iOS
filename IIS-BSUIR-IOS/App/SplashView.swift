//
//  SplashView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI

private enum Constants {
    enum Layout {
        static let progressScale: CGFloat = 1.5
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            ProgressView()
                .scaleEffect(Constants.Layout.progressScale)
        }
    }
}
