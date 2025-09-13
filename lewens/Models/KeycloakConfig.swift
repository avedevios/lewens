//
//  KeycloakConfig.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import Foundation

// Keycloak configuration model
struct KeycloakConfig {
    // Keycloak server URL (change this to your Keycloak server)
    static let serverURL = "http://localhost:8080"
    
    // Realm name
    static let realm = "lewens"
    
    // Client ID for iOS app
    static let clientId = "lewens-ios"
    
    // Redirect URI for OAuth callback
    static let redirectURI = "lewens://auth/callback"
    
    // Scopes to request
    static let scopes = ["openid", "profile", "email"]
    
    // Computed properties for URLs
    static var realmURL: String {
        return "\(serverURL)/realms/\(realm)"
    }
    
    static var authorizationEndpoint: String {
        return "\(realmURL)/protocol/openid-connect/auth"
    }
    
    static var tokenEndpoint: String {
        return "\(realmURL)/protocol/openid-connect/token"
    }
    
    static var userInfoEndpoint: String {
        return "\(realmURL)/protocol/openid-connect/userinfo"
    }
}
