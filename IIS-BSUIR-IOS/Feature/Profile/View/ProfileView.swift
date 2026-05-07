//
//  ProfileView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Factory
import SwiftUI
import UIKit

private enum Constants {
    enum Layout {
        static let avatarSize: CGFloat = 120
        static let avatarBorderWidth: CGFloat = 3
        static let headerSpacing: CGFloat = 6
        static let headerVerticalPadding: CGFloat = 16
        static let starSpacing: CGFloat = 4
    }
    enum Icons {
        static let unauthenticated = "person.fill.questionmark"
        static let personPlaceholder = "person.crop.circle.fill"
        static let starFilled = "star.fill"
        static let starEmpty = "star"
        static let logout = "rectangle.portrait.and.arrow.right"
        static let markBook = "graduationcap"
        static let grades = "list.number"
    }
    enum Colors {
        static let avatarBackground = Color(.secondarySystemGroupedBackground)
    }
    static let maxRating = 5
}

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel = Container.shared.profileViewModel()

    var body: some View {
        if viewModel.isAuthenticated {
            authenticatedView
        } else {
            unauthenticatedView
        }
    }

    private var unauthenticatedView: some View {
        ContentUnavailableView {
            Label("profile.not_authenticated.title", systemImage: Constants.Icons.unauthenticated)
        } description: {
            Text("profile.not_authenticated.description")
        } actions: {
            Button("profile.sign_in") {
                viewModel.didTapSignIn()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("profile.title")
    }

    private var authenticatedView: some View {
        List {
            if let user = viewModel.authenticatedUser {
                Section {
                    profileHeader(user: user)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(
                            top: 0,
                            leading: 0,
                            bottom: Constants.Layout.headerVerticalPadding,
                            trailing: 0
                        ))
                }
            }

            Section {
                Button {
                    viewModel.didTapMarkBook()
                } label: {
                    Label("markbook.title", systemImage: Constants.Icons.markBook)
                }
                Button {
                    viewModel.didTapGrades()
                } label: {
                    Label("grades.title", systemImage: Constants.Icons.grades)
                }
            }
        }
        .navigationTitle("profile.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.didTapLogout()
                } label: {
                    Image(systemName: Constants.Icons.logout)
                        .foregroundStyle(.red)
                        .font(.callout)
                        .fontWeight(.medium)
                }
            }
        }
    }

    private func profileHeader(user: User) -> some View {
        VStack(spacing: Constants.Layout.headerSpacing) {
            profilePhoto(base64: user.photoUrl)

            Text(user.fio)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            let infoLine = [user.faculty, user.speciality, user.course.map { Self.formatCourse($0) }]
                .compactMap { $0 }
                .joined(separator: ", ")
            if !infoLine.isEmpty {
                Text(infoLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let rating = user.rating {
                starRating(rating)
            }
        }
    }

    private static func formatCourse(_ course: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        let ordinal = formatter.string(from: NSNumber(value: course)) ?? "\(course)"
        return String(format: String(localized: "profile.info.course %@"), ordinal)
    }

    private func starRating(_ rating: Int) -> some View {
        HStack(spacing: Constants.Layout.starSpacing) {
            ForEach(1...Constants.maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? Constants.Icons.starFilled : Constants.Icons.starEmpty)
                    .foregroundStyle(star <= rating ? Color.yellow : Color.secondary)
            }
        }
    }

    @ViewBuilder
    private func profilePhoto(base64: String?) -> some View {
        let size = Constants.Layout.avatarSize
        let rawBase64 = base64.flatMap { $0.components(separatedBy: ",").last }
        if let rawBase64,
           let data = Data(base64Encoded: rawBase64, options: .ignoreUnknownCharacters),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .background(Constants.Colors.avatarBackground, in: Circle())
                .clipShape(Circle())
                .padding(Constants.Layout.avatarBorderWidth)
                .background(Constants.Colors.avatarBackground, in: Circle())
        } else {
            Image(systemName: Constants.Icons.personPlaceholder)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .background(Constants.Colors.avatarBackground, in: Circle())
                .padding(Constants.Layout.avatarBorderWidth)
                .background(Constants.Colors.avatarBackground, in: Circle())
                .foregroundStyle(.secondary)
        }
    }
}
