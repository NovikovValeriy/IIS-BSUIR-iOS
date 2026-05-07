//
//  OfflineBannerView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 03.05.26.
//

import SwiftUI

private enum Constants {
    enum Layout {
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 6
        static let bottomPadding: CGFloat = 8
        static let iconSpacing: CGFloat = 8
    }
    enum Icons {
        static let offline = "wifi.slash"
    }
}

struct OfflineBannerView: View {
    var body: some View {
        HStack(spacing: Constants.Layout.iconSpacing) {
            Image(systemName: Constants.Icons.offline)
                .font(.footnote)
            Text("schedule.offline.banner")
                .font(.footnote)
        }
        .padding(.horizontal, Constants.Layout.horizontalPadding)
        .padding(.vertical, Constants.Layout.verticalPadding)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.bottom, Constants.Layout.bottomPadding)
    }
}
