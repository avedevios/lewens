//
//  KeycloakConfig.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import Foundation

// Keycloak configuration — values loaded from Config.plist (not tracked in git)
// Copy Config.plist.example to Config.plist and fill in your values
struct KeycloakConfig {
    private static let config: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String: Any] else {
            fatalError("Config.plist not found. Copy Config.plist.example to Config.plist and fill in your values.")
        }
        return dict
    }()

    static var serverURL: String {
        config["KeycloakServerURL"] as? String ?? ""
    }

    static var realm: String {
        config["KeycloakRealm"] as? String ?? ""
    }

    static var clientId: String {
        config["KeycloakClientId"] as? String ?? ""
    }

    static var redirectURI: String {
        config["KeycloakRedirectURI"] as? String ?? ""
    }

    // Scopes to request
    static let scopes = ["openid", "profile", "email"]

    static var appleClientId: String {
        config["AppleClientId"] as? String ?? ""
    }

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
