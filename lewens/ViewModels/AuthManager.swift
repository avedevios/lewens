//
//  AuthManager.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import Foundation
import SwiftUI

// Simple authentication manager
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    
    // Singleton for global access
    static let shared = AuthManager()
    
    private init() {
        // Check for stored user data
        checkStoredAuth()
    }
    
    // Simple login method (without Keycloak for now)
    func login(email: String, password: String) {
        isLoading = true
        
        // Simulate server request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // For now, just check that fields are not empty
            if !email.isEmpty && !password.isEmpty {
                // Create test user
                let user = User(
                    id: UUID().uuidString,
                    email: email,
                    firstName: "Test",
                    lastName: "User",
                    username: email.components(separatedBy: "@").first
                )
                
                self.currentUser = user
                self.isAuthenticated = true
                self.saveAuthData()
            }
            
            self.isLoading = false
        }
    }
    
    // Logout from system
    func logout() {
        currentUser = nil
        isAuthenticated = false
        clearAuthData()
    }
    
    // Check stored authentication data
    private func checkStoredAuth() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    // Save user data
    private func saveAuthData() {
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    // Clear stored data
    private func clearAuthData() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
}
