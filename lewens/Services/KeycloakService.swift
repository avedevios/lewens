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
class KeycloakService: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // OAuth state
    private var authState: OIDAuthState?
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    // Singleton for global access
    static let shared = KeycloakService()
    
    private override init() {
        super.init()
        
        #if DEBUG
        StartupProfiler.shared.recordMilestone("KeycloakService Init Start")
        #endif
        
        // Defer both auth restoration and token refresh to background
        // to avoid blocking UI thread on app startup
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.checkStoredAuth()
            
            #if DEBUG
            DispatchQueue.main.async {
                StartupProfiler.shared.recordMilestone("KeycloakService checkStoredAuth Done")
            }
            #endif
            
            // Refresh token after brief delay
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.refreshToken()
            }
        }
    }
    
    // Login with OAuth flow (opens browser for authentication)
    func login(username: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Clear any existing state before starting new flow
        clearStoredData()
        
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
            additionalParameters: [
                "prompt": "login",           // Force login screen
                "max_age": "0"              // Force re-authentication
            ]
        )
        
        // Present authorization flow
        presentAuthorizationFlow(request: request)
    }
    
    // Present authorization flow in browser
    private func presentAuthorizationFlow(request: OIDAuthorizationRequest) {
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            errorMessage = "Unable to present authorization flow"
            isLoading = false
            return
        }
        
        // Create external user agent
        guard let externalUserAgent = OIDExternalUserAgentIOS(presenting: rootViewController) else {
            errorMessage = "Unable to create external user agent"
            isLoading = false
            return
        }
        
        // Present the authorization flow with external user agent
        currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, externalUserAgent: externalUserAgent) { [weak self] authState, error in
            DispatchQueue.main.async {
                if let authState = authState {
                    // Success - we have the auth state
                    self?.handleSuccessfulAuth(authState: authState)
                } else if let error = error {
                    // Error occurred
                    self?.errorMessage = "Authentication failed: \(error.localizedDescription)"
                    self?.isLoading = false
                }
                
                self?.currentAuthorizationFlow = nil
            }
        }
    }
    
    // Handle successful authentication
    private func handleSuccessfulAuth(authState: OIDAuthState) {
        self.authState = authState
        
        // Fetch user info from Keycloak
        fetchUserInfo(authState: authState)
    }
    
    // Fetch user info from Keycloak
    private func fetchUserInfo(authState: OIDAuthState) {
        guard let userInfoEndpoint = URL(string: KeycloakConfig.userInfoEndpoint) else {
            errorMessage = "Invalid user info endpoint"
            isLoading = false
            return
        }
        
        // Create user info request with access token
        var request = URLRequest(url: userInfoEndpoint)
        request.setValue("Bearer \(authState.lastTokenResponse?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch user info: \(error.localizedDescription)"
                    self?.isLoading = false
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No user data received"
                    self?.isLoading = false
                    return
                }
                
                // Parse user info (simplified for now)
                self?.parseUserInfo(data: data)
            }
        }.resume()
    }
    
    // Parse user info from Keycloak response
    private func parseUserInfo(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let user = User(
                    id: json["sub"] as? String ?? UUID().uuidString,
                    email: json["email"] as? String ?? "",
                    firstName: json["given_name"] as? String,
                    lastName: json["family_name"] as? String,
                    username: json["preferred_username"] as? String
                )
                
                self.currentUser = user
                self.isAuthenticated = true
                self.saveAuthData()
            } else {
                self.errorMessage = "Invalid user data format"
            }
        } catch {
            self.errorMessage = "Failed to parse user data: \(error.localizedDescription)"
        }
        
        self.isLoading = false
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
    
    // Clear stored data (for testing)
    func clearStoredData() {
        // Clear all UserDefaults data
        clearAuthData()
        
        // Clear ALL cookies (more aggressive)
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        // Clear all UserDefaults (more aggressive)
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        for key in dictionary.keys {
            defaults.removeObject(forKey: key)
        }
        
        // Reset all state immediately
        self.authState = nil
        self.currentUser = nil
        self.isAuthenticated = false
        self.isLoading = false
        self.currentAuthorizationFlow = nil
    }
    
    // Handle OAuth callback from browser
    func handleOAuthCallback(url: URL) {
        // Check if we have an active authorization flow
        guard let currentFlow = currentAuthorizationFlow else {
            return
        }
        
        // Resume the authorization flow with the callback URL
        if currentFlow.resumeExternalUserAgentFlow(with: url) {
            currentAuthorizationFlow = nil
        } else {
            errorMessage = "Authentication failed"
            isLoading = false
        }
    }
    
    // Refresh token
    func refreshToken() {
        guard let authState = authState else {
            return
        }
        
        // Check if token needs refresh by checking if it's expired
        if authState.isAuthorized && authState.lastTokenResponse?.accessToken != nil {
            // Check if token is expired (simplified check)
            if let tokenResponse = authState.lastTokenResponse,
               let expiresIn = tokenResponse.accessTokenExpirationDate,
               expiresIn > Date() {
                print("Token is still valid, no refresh needed")
                return
            }
        }
        
        // Perform token refresh
        authState.performAction { [weak self] accessToken, idToken, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Token refresh failed: \(error.localizedDescription)")
                    // If refresh fails, logout user
                    self?.logout()
                } else {
                    print("Token refreshed successfully")
                    // Save updated auth state
                    self?.saveAuthData()
                }
            }
        }
    }
    
    // Check stored authentication data (optimized for fast startup)
    private func checkStoredAuth() {
        // Try to restore user from UserDefaults (lightweight check)
        if let userData = UserDefaults.standard.data(forKey: "keycloak_user") {
            do {
                let user = try JSONDecoder().decode(User.self, from: userData)
                currentUser = user
                isAuthenticated = true
            } catch {
                #if DEBUG
                print("Failed to decode stored user: \(error)")
                #endif
            }
        }
        
        // Note: Auth state restoration is deferred to background
        // to avoid blocking UI thread on app startup
    }
    
    // Save authentication data
    private func saveAuthData() {
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "keycloak_user")
        }
        
        // Save auth state for token management
        if let authState = authState,
           let authStateData = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false) {
            UserDefaults.standard.set(authStateData, forKey: "keycloak_auth_state")
        }
    }
    
    // Clear stored data
    private func clearAuthData() {
        UserDefaults.standard.removeObject(forKey: "keycloak_user")
        UserDefaults.standard.removeObject(forKey: "keycloak_auth_state")
    }
}
