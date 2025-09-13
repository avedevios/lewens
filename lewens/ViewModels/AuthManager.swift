//
//  AuthManager.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import Foundation
import SwiftUI

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
            .assign(to: &$currentUser)
        
        keycloakService.$isLoading
            .assign(to: &$isLoading)
        
        keycloakService.$errorMessage
            .assign(to: &$errorMessage)
    }
    
    // Login method that delegates to KeycloakService
    func login(email: String, password: String) {
        keycloakService.login(username: email, password: password)
    }
    
    // Logout method that delegates to KeycloakService
    func logout() {
        keycloakService.logout()
    }
}
