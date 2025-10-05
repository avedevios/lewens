//
//  AuthManager.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import Foundation
import SwiftUI
import Combine

// Authentication manager that uses KeycloakService
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Singleton for global access
    static let shared = AuthManager()
    
    // Keycloak service
    private let keycloakService = KeycloakService.shared
    
    private init() {
        // Subscribe to KeycloakService changes
        keycloakService.$isAuthenticated
            .assign(to: &$isAuthenticated)
        
        keycloakService.$currentUser
            .sink { [weak self] user in
                self?.currentUser = user
                if let user = user {
                    // User logged in
                    NotificationCenter.default.post(
                        name: .userDidLogin,
                        object: nil,
                        userInfo: ["user": user]
                    )
                }
            }
            .store(in: &cancellables)
        
        keycloakService.$isLoading
            .assign(to: &$isLoading)
        
        keycloakService.$errorMessage
            .assign(to: &$errorMessage)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // Login method that delegates to KeycloakService
    func login(email: String, password: String) {
        keycloakService.login(username: email, password: password)
    }
    
    // Logout method that delegates to KeycloakService
    func logout() {
        // Send logout notification before clearing user
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
        keycloakService.logout()
    }
}
