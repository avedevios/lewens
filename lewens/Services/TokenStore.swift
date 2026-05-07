//
//  TokenStore.swift
//  lewens
//
//  Responsible for persisting and restoring OIDAuthState and User.
//

import Foundation
import AppAuth

final class TokenStore {

    private enum Keys {
        static let authState = "auth_state"
        static let user      = "keycloak_user"
        static let service   = "lewens-ios"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Auth State

    func saveAuthState(_ authState: OIDAuthState) {
        guard let data = try? NSKeyedArchiver.archivedData(
            withRootObject: authState,
            requiringSecureCoding: true
        ) else { return }
        KeychainHelper.shared.save(data, service: Keys.service, account: Keys.authState)
    }

    func loadAuthState() -> OIDAuthState? {
        guard let data = KeychainHelper.shared.read(service: Keys.service, account: Keys.authState) else {
            return nil
        }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data)
    }

    func deleteAuthState() {
        KeychainHelper.shared.delete(service: Keys.service, account: Keys.authState)
    }

    // MARK: - User

    func saveUser(_ user: User) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        defaults.set(data, forKey: Keys.user)
    }

    func loadUser() -> User? {
        guard let data = defaults.data(forKey: Keys.user) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    func deleteUser() {
        defaults.removeObject(forKey: Keys.user)
        defaults.removeObject(forKey: "keycloak_auth_state")
    }

    // MARK: - Clear all

    func clearAll() {
        deleteAuthState()
        deleteUser()
    }
}
