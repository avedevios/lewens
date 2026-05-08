//
//  StringLocalizationTests.swift
//  lewensTests
//

import Testing
import Foundation
@testable import lewens

@Suite("String.localized extension", .serialized)
@MainActor
struct StringLocalizationTests {

    @Test("Known key returns non-empty string")
    func knownKeyNonEmpty() {
        LocalizationManager.shared.currentLanguage = "en"
        defer { LocalizationManager.shared.currentLanguage = "de" }

        #expect(!LocalizationKeys.signIn.localized.isEmpty)
    }

    @Test("Unknown key returns the key itself")
    func unknownKeyReturnsSelf() {
        let key = "totally_unknown_key_abc123"
        #expect(key.localized == key)
    }

    @Test("localized changes with language", arguments: ["de", "en", "pl"])
    @MainActor
    func localizedChangesWithLanguage(language: String) {
        let original = LocalizationManager.shared.currentLanguage
        defer { LocalizationManager.shared.currentLanguage = original }

        LocalizationManager.shared.currentLanguage = language
        #expect(!LocalizationKeys.signIn.localized.isEmpty)
    }

    @Test("Format string substitution works")
    func formatStringSubstitution() {
        let result = "Hello %@".localized(with: "World")
        #expect(result == "Hello World")
    }

    @Test("Multiple format arguments")
    func multipleFormatArguments() {
        let result = "%@ has %d items".localized(with: "Cart", 3)
        #expect(result == "Cart has 3 items")
    }
}
