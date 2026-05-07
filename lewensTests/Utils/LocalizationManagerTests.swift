//
//  LocalizationManagerTests.swift
//  lewensTests
//

import Testing
import Foundation
@testable import lewens

@Suite("LocalizationManager", .serialized)
struct LocalizationManagerTests {

    private var sut: LocalizationManager { .shared }

    // MARK: - Supported languages

    @Test("Contains all expected language codes")
    func supportedLanguageCodes() {
        #expect(sut.supportedLanguages["de"] != nil)
        #expect(sut.supportedLanguages["en"] != nil)
        #expect(sut.supportedLanguages["pl"] != nil)
    }

    @Test("Language names are correct", arguments: [
        ("de", "Deutsch"),
        ("en", "English"),
        ("pl", "Polski"),
    ])
    func languageNames(code: String, expectedName: String) {
        #expect(sut.supportedLanguages[code] == expectedName)
    }

    // MARK: - getLanguageName

    @Test("getLanguageName returns correct name", arguments: [
        ("de", "Deutsch"),
        ("en", "English"),
        ("pl", "Polski"),
    ])
    func getLanguageName(code: String, expected: String) {
        #expect(sut.getLanguageName(for: code) == expected)
    }

    @Test("getLanguageName returns code for unknown language", arguments: ["fr", "xx", "zh"])
    func getLanguageName_unknown(code: String) {
        #expect(sut.getLanguageName(for: code) == code)
    }

    // MARK: - Language switching

    @Test("Switching language changes currentLanguage")
    func switchLanguage() {
        let original = sut.currentLanguage
        defer { sut.currentLanguage = original }

        sut.currentLanguage = "en"
        #expect(sut.currentLanguage == "en")

        sut.currentLanguage = "pl"
        #expect(sut.currentLanguage == "pl")
    }

    @Test("Language change persists to UserDefaults")
    func languagePersistsToUserDefaults() {
        let original = sut.currentLanguage
        defer {
            sut.currentLanguage = original
            UserDefaults.standard.set(original, forKey: "AppLanguage")
        }

        sut.currentLanguage = "en"
        #expect(UserDefaults.standard.string(forKey: "AppLanguage") == "en")
    }

    // MARK: - localizedString

    @Test("Returns key itself for unknown key")
    func unknownKeyReturnsSelf() {
        let key = "nonexistent_key_xyz_\(UUID())"
        #expect(sut.localizedString(for: key) == key)
    }

    @Test("Returns empty string for empty key")
    func emptyKeyReturnsEmpty() {
        #expect(sut.localizedString(for: "") == "")
    }

    @Test("Known keys return non-empty strings in all languages", arguments: ["de", "en", "pl"])
    func knownKeysNonEmpty(language: String) {
        let original = sut.currentLanguage
        defer { sut.currentLanguage = original }

        sut.currentLanguage = language

        let keys = [
            LocalizationKeys.authentication,
            LocalizationKeys.signIn,
            LocalizationKeys.signOut,
            LocalizationKeys.downloads,
            LocalizationKeys.profile,
            LocalizationKeys.customers,
            LocalizationKeys.copyright,
            LocalizationKeys.welcome,
        ]

        for key in keys {
            #expect(
                !sut.localizedString(for: key).isEmpty,
                "Key '\(key)' is empty for language '\(language)'"
            )
        }
    }

    // MARK: - LocalizationKeys

    @Test("All LocalizationKeys are non-empty strings")
    func allKeysNonEmpty() {
        let allKeys = [
            LocalizationKeys.authentication,
            LocalizationKeys.signInDescription,
            LocalizationKeys.openingBrowser,
            LocalizationKeys.signInKeycloak,
            LocalizationKeys.copyright,
            LocalizationKeys.welcome,
            LocalizationKeys.signOut,
            LocalizationKeys.language,
            LocalizationKeys.downloads,
            LocalizationKeys.signIn,
            LocalizationKeys.profile,
            LocalizationKeys.customers,
            LocalizationKeys.downloadsDescription,
            LocalizationKeys.documents,
            LocalizationKeys.videos,
            LocalizationKeys.customersDescription,
        ]

        for key in allKeys {
            #expect(!key.isEmpty, "LocalizationKey '\(key)' should not be empty")
        }
    }

    @Test("All LocalizationKeys are unique")
    func allKeysUnique() {
        let allKeys = [
            LocalizationKeys.authentication,
            LocalizationKeys.signInDescription,
            LocalizationKeys.openingBrowser,
            LocalizationKeys.signInKeycloak,
            LocalizationKeys.copyright,
            LocalizationKeys.welcome,
            LocalizationKeys.signOut,
            LocalizationKeys.language,
            LocalizationKeys.downloads,
            LocalizationKeys.signIn,
            LocalizationKeys.profile,
            LocalizationKeys.customers,
            LocalizationKeys.downloadsDescription,
            LocalizationKeys.documents,
            LocalizationKeys.videos,
            LocalizationKeys.customersDescription,
        ]

        #expect(Set(allKeys).count == allKeys.count)
    }
}
