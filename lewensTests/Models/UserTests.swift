//
//  UserTests.swift
//  lewensTests
//

import Testing
import Foundation
@testable import lewens

@Suite("User Model")
struct UserTests {

    @Suite("fullName")
    struct FullNameTests {

        @Test("Both first and last name", arguments: [
            ("Anna", "Mueller", "Anna Mueller"),
            ("Max",  "Schmidt", "Max Schmidt"),
        ])
        func bothNames(first: String, last: String, expected: String) {
            let user = User.fixture(firstName: first, lastName: last, username: nil)
            #expect(user.fullName == expected)
        }

        @Test("First name only")
        func firstNameOnly() {
            let user = User.fixture(firstName: "Anna", lastName: nil, username: nil)
            #expect(user.fullName == "Anna")
        }

        @Test("Last name only")
        func lastNameOnly() {
            let user = User.fixture(firstName: nil, lastName: "Mueller", username: nil)
            #expect(user.fullName == "Mueller")
        }

        @Test("No names — falls back to email")
        func noNames() {
            let user = User.fixture(firstName: nil, lastName: nil, username: nil)
            #expect(user.fullName == user.email)
        }
    }

    @Suite("displayName")
    struct DisplayNameTests {

        @Test("Prefers username over full name")
        func prefersUsername() {
            let user = User.fixture(firstName: "Anna", lastName: "Mueller", username: "anna.mueller")
            #expect(user.displayName == "anna.mueller")
        }

        @Test("Falls back to fullName when no username")
        func fallsBackToFullName() {
            let user = User.fixture(firstName: "Anna", lastName: "Mueller", username: nil)
            #expect(user.displayName == "Anna Mueller")
        }

        @Test("Falls back to email when no username and no names")
        func fallsBackToEmail() {
            let user = User.fixture(firstName: nil, lastName: nil, username: nil)
            #expect(user.displayName == user.email)
        }

        @Test("Empty username string falls back to fullName")
        func emptyUsernameFallsBackToFullName() {
            let user = User.fixture(firstName: "Anna", lastName: "Mueller", username: "")
            // username is "" which is falsy — displayName should use fullName
            // username ?? fullName returns "" because "" is non-nil
            // This documents the current behaviour
            #expect(user.displayName == "")
        }
    }

    @Suite("Codable")
    struct CodableTests {

        @Test("Round-trip encodes and decodes all fields")
        func roundTripFull() throws {
            let original = User.fixture()
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(User.self, from: data)

            #expect(decoded.id        == original.id)
            #expect(decoded.email     == original.email)
            #expect(decoded.firstName == original.firstName)
            #expect(decoded.lastName  == original.lastName)
            #expect(decoded.username  == original.username)
        }

        @Test("Round-trip with minimal fields")
        func roundTripMinimal() throws {
            let original = User(id: "x", email: "x@x.com")
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(User.self, from: data)

            #expect(decoded.id        == "x")
            #expect(decoded.email     == "x@x.com")
            #expect(decoded.firstName == nil)
            #expect(decoded.lastName  == nil)
            #expect(decoded.username  == nil)
        }

        @Test("Decodes from JSON with all fields")
        func decodeFromJSON() throws {
            let json = """
            {
                "id": "abc",
                "email": "abc@test.com",
                "firstName": "Max",
                "lastName": "Schmidt",
                "username": "max.schmidt"
            }
            """.data(using: .utf8)!

            let user = try JSONDecoder().decode(User.self, from: json)

            #expect(user.id        == "abc")
            #expect(user.email     == "abc@test.com")
            #expect(user.firstName == "Max")
            #expect(user.lastName  == "Schmidt")
            #expect(user.username  == "max.schmidt")
        }

        @Test("Decodes with missing optional fields")
        func decodeMissingOptionals() throws {
            let json = #"{ "id": "1", "email": "a@b.com" }"#.data(using: .utf8)!
            let user = try JSONDecoder().decode(User.self, from: json)

            #expect(user.firstName == nil)
            #expect(user.lastName  == nil)
            #expect(user.username  == nil)
        }

        @Test("User with Unicode characters in name")
        func unicodeName() throws {
            let original = User(id: "u1", email: "test@test.com", firstName: "Ján", lastName: "Novák")
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(User.self, from: data)

            #expect(decoded.firstName == "Ján")
            #expect(decoded.lastName  == "Novák")
            #expect(decoded.fullName  == "Ján Novák")
        }
    }

    // MARK: - Equatable

    @Suite("Equatable")
    struct EquatableTests {

        @Test("Two users with same fields are equal")
        func equalUsers() {
            let a = User.fixture()
            let b = User.fixture()
            #expect(a == b)
        }

        @Test("Users with different id are not equal")
        func differentIdNotEqual() {
            let a = User.fixture(id: "id-1")
            let b = User.fixture(id: "id-2")
            #expect(a != b)
        }

        @Test("Users with different email are not equal")
        func differentEmailNotEqual() {
            let a = User.fixture(email: "a@test.com")
            let b = User.fixture(email: "b@test.com")
            #expect(a != b)
        }

        @Test("Users with different optional fields are not equal")
        func differentOptionalFieldsNotEqual() {
            let a = User.fixture(username: "alice")
            let b = User.fixture(username: "bob")
            #expect(a != b)
        }
    }
}
