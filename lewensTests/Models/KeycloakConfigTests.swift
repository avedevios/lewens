//
//  KeycloakConfigTests.swift
//  lewensTests
//

import Testing
import Foundation
@testable import lewens

@Suite("KeycloakConfig")
struct KeycloakConfigTests {

    // MARK: - URL construction

    @Test("realmURL is built from serverURL and realm")
    func realmURL() {
        let expected = "\(KeycloakConfig.serverURL)/realms/\(KeycloakConfig.realm)"
        #expect(KeycloakConfig.realmURL == expected)
    }

    @Test("authorizationEndpoint ends with /protocol/openid-connect/auth")
    func authorizationEndpoint() {
        #expect(KeycloakConfig.authorizationEndpoint.hasSuffix("/protocol/openid-connect/auth"))
    }

    @Test("tokenEndpoint ends with /protocol/openid-connect/token")
    func tokenEndpoint() {
        #expect(KeycloakConfig.tokenEndpoint.hasSuffix("/protocol/openid-connect/token"))
    }

    @Test("userInfoEndpoint ends with /protocol/openid-connect/userinfo")
    func userInfoEndpoint() {
        #expect(KeycloakConfig.userInfoEndpoint.hasSuffix("/protocol/openid-connect/userinfo"))
    }

    @Test("All endpoints start with realmURL")
    func endpointsStartWithRealmURL() {
        let realmURL = KeycloakConfig.realmURL
        #expect(KeycloakConfig.authorizationEndpoint.hasPrefix(realmURL))
        #expect(KeycloakConfig.tokenEndpoint.hasPrefix(realmURL))
        #expect(KeycloakConfig.userInfoEndpoint.hasPrefix(realmURL))
    }

    @Test("All endpoints are valid URLs")
    func endpointsAreValidURLs() {
        #expect(URL(string: KeycloakConfig.authorizationEndpoint) != nil)
        #expect(URL(string: KeycloakConfig.tokenEndpoint) != nil)
        #expect(URL(string: KeycloakConfig.userInfoEndpoint) != nil)
        #expect(URL(string: KeycloakConfig.redirectURI) != nil)
    }

    // MARK: - Scopes

    @Test("scopes contains openid, profile, email")
    func scopesContainRequired() {
        #expect(KeycloakConfig.scopes.contains("openid"))
        #expect(KeycloakConfig.scopes.contains("profile"))
        #expect(KeycloakConfig.scopes.contains("email"))
    }

    @Test("scopes has exactly 3 entries")
    func scopesCount() {
        #expect(KeycloakConfig.scopes.count == 3)
    }

    // MARK: - Non-empty values

    @Test("Required config values are non-empty")
    func requiredValuesNonEmpty() {
        #expect(!KeycloakConfig.serverURL.isEmpty)
        #expect(!KeycloakConfig.realm.isEmpty)
        #expect(!KeycloakConfig.clientId.isEmpty)
        #expect(!KeycloakConfig.redirectURI.isEmpty)
        #expect(!KeycloakConfig.apiBaseURL.isEmpty)
    }

    @Test("redirectURI uses lewens scheme")
    func redirectURIScheme() {
        #expect(KeycloakConfig.redirectURI.hasPrefix("lewens://"))
    }
}
