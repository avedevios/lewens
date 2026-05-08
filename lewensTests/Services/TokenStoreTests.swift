//
//  TokenStoreTests.swift
//  lewensTests
//

import Testing
import Foundation
@testable import lewens

@Suite("TokenStore", .serialized) // serialized — Keychain is not thread-safe across tests
struct TokenStoreTests {

    private let suiteName = "lewensTests.TokenStore"

    private func makeSUT() -> (TokenStore, UserDefaults) {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = TokenStore(defaults: defaults)
        store.deleteAuthState()
        return (store, defaults)
    }

    // MARK: - User persistence

    @Test("Saves and loads user correctly")
    func saveAndLoadUser() {
        let (sut, _) = makeSUT()
        let user = User.fixture()

        sut.saveUser(user)
        let loaded = sut.loadUser()

        #expect(loaded?.id        == user.id)
        #expect(loaded?.email     == user.email)
        #expect(loaded?.firstName == user.firstName)
        #expect(loaded?.lastName  == user.lastName)
        #expect(loaded?.username  == user.username)
    }

    @Test("Returns nil when no user saved")
    func loadUser_returnsNil() {
        let (sut, _) = makeSUT()
        #expect(sut.loadUser() == nil)
    }

    @Test("Delete removes saved user")
    func deleteUser() {
        let (sut, _) = makeSUT()
        sut.saveUser(.fixture())
        sut.deleteUser()
        #expect(sut.loadUser() == nil)
    }

    @Test("Overwrite replaces previous user")
    func overwriteUser() {
        let (sut, _) = makeSUT()
        sut.saveUser(.fixture(email: "first@test.com"))
        sut.saveUser(.fixture(email: "second@test.com"))
        #expect(sut.loadUser()?.email == "second@test.com")
    }

    @Test("clearAll removes user")
    func clearAllRemovesUser() {
        let (sut, _) = makeSUT()
        sut.saveUser(.fixture())
        sut.clearAll()
        #expect(sut.loadUser() == nil)
    }

    @Test("Saves user with all nil optional fields")
    func saveUserWithNilFields() {
        let (sut, _) = makeSUT()
        let user = User(id: "min", email: "min@test.com")
        sut.saveUser(user)

        let loaded = sut.loadUser()
        #expect(loaded?.id        == "min")
        #expect(loaded?.firstName == nil)
        #expect(loaded?.lastName  == nil)
        #expect(loaded?.username  == nil)
    }

    // MARK: - Keychain

    @Test("loadAuthState returns nil when nothing saved")
    func loadAuthState_returnsNil() {
        let (sut, _) = makeSUT()
        #expect(sut.loadAuthState() == nil)
    }

    @Test("deleteAuthState does not crash when nothing saved")
    func deleteAuthState_noCrash() {
        let (sut, _) = makeSUT()
        sut.deleteAuthState()
        #expect(sut.loadAuthState() == nil)
    }

    @Test("clearAll does not crash on empty store")
    func clearAll_noCrash() {
        let (sut, _) = makeSUT()
        sut.clearAll()
        #expect(sut.loadUser() == nil)
        #expect(sut.loadAuthState() == nil)
    }

    @Test("User with Unicode characters round-trips correctly")
    func unicodeUserRoundTrip() {
        let (sut, _) = makeSUT()
        let user = User(id: "u1", email: "jan@test.com", firstName: "Ján", lastName: "Novák")
        sut.saveUser(user)

        let loaded = sut.loadUser()
        #expect(loaded?.firstName == "Ján")
        #expect(loaded?.lastName  == "Novák")
    }

    @Test("deleteUser also removes legacy keycloak_auth_state key")
    func deleteUserRemovesLegacyKey() {
        let (sut, defaults) = makeSUT()
        defaults.set("legacy_value", forKey: "keycloak_auth_state")
        sut.deleteUser()
        #expect(defaults.string(forKey: "keycloak_auth_state") == nil)
    }

    @Test("Two separate TokenStore instances with different UserDefaults are isolated")
    func separateInstancesAreIsolated() {
        let defaults1 = UserDefaults(suiteName: "lewensTests.TokenStore.A")!
        let defaults2 = UserDefaults(suiteName: "lewensTests.TokenStore.B")!
        defaults1.removePersistentDomain(forName: "lewensTests.TokenStore.A")
        defaults2.removePersistentDomain(forName: "lewensTests.TokenStore.B")

        let store1 = TokenStore(defaults: defaults1)
        let store2 = TokenStore(defaults: defaults2)

        store1.saveUser(.fixture(email: "store1@test.com"))
        store2.saveUser(.fixture(email: "store2@test.com"))

        #expect(store1.loadUser()?.email == "store1@test.com")
        #expect(store2.loadUser()?.email == "store2@test.com")

        defaults1.removePersistentDomain(forName: "lewensTests.TokenStore.A")
        defaults2.removePersistentDomain(forName: "lewensTests.TokenStore.B")
    }
}
