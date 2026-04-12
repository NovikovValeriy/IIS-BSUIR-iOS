//
//  AuthState.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation
import Observation

enum AuthStatus {
    case unauthenticated
    case authenticated(user: LoginResponseDTO)
}

extension AuthStatus: Equatable {
    static func == (lhs: AuthStatus, rhs: AuthStatus) -> Bool {
        switch (lhs, rhs) {
        case (.unauthenticated, .unauthenticated): return true
        case (.authenticated(let left), .authenticated(let right)): return left.username == right.username
        default: return false
        }
    }
}

@Observable
@MainActor
final class AuthState {
    private(set) var status: AuthStatus = .unauthenticated

    func transition(to status: AuthStatus) {
        self.status = status
    }
}
