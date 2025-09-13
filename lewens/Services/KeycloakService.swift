//
//  KeycloakService.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import Foundation
import Combine

// Keycloak service for authentication
class KeycloakService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Singleton for global access
    static let shared = KeycloakService()
    
    private init() {
        // Check for stored authentication data
        checkStoredAuth()
    }
    
    // Login with username and password (for now, just a placeholder)
    func login(username: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement real Keycloak authentication
        // For now, simulate a successful login
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !username.isEmpty && !password.isEmpty {
                // Create a test user (will be replaced with real Keycloak user data)
                let user = User(
                    id: UUID().uuidString,
                    email: username,
                    firstName: "Keycloak",
                    lastName: "User",
                    username: username
                )
                
                self.currentUser = user
                self.isAuthenticated = true
                self.saveAuthData()
            } else {
                self.errorMessage = "Username and password are required"
            }
            
            self.isLoading = false
        }
    }
    
    // Logout from Keycloak
    func logout() {
        // TODO: Implement real Keycloak logout
        currentUser = nil
        isAuthenticated = false
        clearAuthData()
    }
    
    // Refresh token (placeholder)
    func refreshToken() {
        // TODO: Implement token refresh
        print("Token refresh not implemented yet")
    }
    
    // Check stored authentication data
    private func checkStoredAuth() {
        if let userData = UserDefaults.standard.data(forKey: "keycloak_user"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    // Save authentication data
    private func saveAuthData() {
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "keycloak_user")
        }
    }
    
    // Clear stored data
    private func clearAuthData() {
        UserDefaults.standard.removeObject(forKey: "keycloak_user")
    }
}
