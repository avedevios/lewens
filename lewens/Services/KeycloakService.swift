//
//  KeycloakService.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import Foundation
import Combine
import AppAuth

// Keycloak service for authentication
class KeycloakService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // OAuth state
    private var authState: OIDAuthState?
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    // Singleton for global access
    static let shared = KeycloakService()
    
    private init() {
        // Check for stored authentication data
        checkStoredAuth()
    }
    
    // Login with OAuth flow (opens browser for authentication)
    func login(username: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Start OAuth authorization flow
        startAuthorizationFlow()
    }
    
    // Start OAuth authorization flow
    private func startAuthorizationFlow() {
        // Create service configuration
        guard let authorizationEndpoint = URL(string: KeycloakConfig.authorizationEndpoint),
              let tokenEndpoint = URL(string: KeycloakConfig.tokenEndpoint) else {
            errorMessage = "Invalid Keycloak configuration"
            isLoading = false
            return
        }
        
        let configuration = OIDServiceConfiguration(
            authorizationEndpoint: authorizationEndpoint,
            tokenEndpoint: tokenEndpoint
        )
        
        // Create authorization request
        guard let redirectURI = URL(string: KeycloakConfig.redirectURI) else {
            errorMessage = "Invalid redirect URI"
            isLoading = false
            return
        }
        
        let request = OIDAuthorizationRequest(
            configuration: configuration,
            clientId: KeycloakConfig.clientId,
            scopes: KeycloakConfig.scopes,
            redirectURL: redirectURI,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil
        )
        
        // Present authorization flow
        // Note: This requires a presenting view controller
        // For now, we'll simulate the flow
        simulateAuthorizationFlow()
    }
    
    // Simulate authorization flow (will be replaced with real implementation)
    private func simulateAuthorizationFlow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Simulate successful authentication
            let user = User(
                id: UUID().uuidString,
                email: "user@example.com",
                firstName: "Keycloak",
                lastName: "User",
                username: "keycloak_user"
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            self.saveAuthData()
            self.isLoading = false
        }
    }
    
    // Logout from Keycloak
    func logout() {
        // Clear OAuth state
        authState = nil
        currentAuthorizationFlow = nil
        
        // Clear user data
        currentUser = nil
        isAuthenticated = false
        clearAuthData()
    }
    
    // Handle OAuth callback from browser
    func handleOAuthCallback(url: URL) {
        // Check if we have an active authorization flow
        guard let currentFlow = currentAuthorizationFlow else {
            print("No active authorization flow")
            return
        }
        
        // Resume the authorization flow with the callback URL
        if currentFlow.resumeExternalUserAgentFlow(with: url) {
            currentAuthorizationFlow = nil
            print("OAuth callback handled successfully")
        } else {
            print("Failed to handle OAuth callback")
            errorMessage = "Authentication failed"
            isLoading = false
        }
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
