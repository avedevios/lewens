//
//  LocalizationHelper.swift
//  lewens
//

import Foundation
import SwiftUI

extension String {
    /// Returns localized string for the current key using LocalizationManager
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    /// Returns localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        let localizedString = LocalizationManager.shared.localizedString(for: self)
        return String(format: localizedString, arguments: arguments)
    }
}

// MARK: - LocalizationManager

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    // MARK: Supported languages

    let supportedLanguages: [String: String] = [
        "de": "Deutsch",
        "en": "English",
        "pl": "Polski"
    ]

    @Published var currentLanguage: String {
        didSet {
            _cachedBundle = nil
            UserDefaults.standard.set(currentLanguage, forKey: "AppLanguage")
        }
    }

    private var _cachedBundle: Bundle?
    private var bundle: Bundle {
        if _cachedBundle == nil {
            loadCurrentBundle()
        }
        return _cachedBundle ?? Bundle.main
    }

    private init() {
        self.currentLanguage = Self.resolveInitialLanguage()
    }

    // MARK: Public API

    func localizedString(for key: String) -> String {
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }

    func getLanguageName(for code: String) -> String {
        return supportedLanguages[code] ?? code
    }

    // MARK: Private helpers

    private func loadCurrentBundle() {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            _cachedBundle = Bundle.main
            return
        }
        _cachedBundle = bundle
    }

    private static func resolveInitialLanguage() -> String {
        if let saved = UserDefaults.standard.string(forKey: "AppLanguage"),
           ["de", "en", "pl"].contains(saved) {
            return saved
        }
        for code in Locale.preferredLanguages.map({ String($0.prefix(2)) }) {
            if ["de", "en", "pl"].contains(code) { return code }
        }
        return "de"
    }
}

// MARK: - LanguageManager (alias for backward compatibility)

typealias LanguageManager = LocalizationManager

// MARK: - LocalizationKeys

struct LocalizationKeys {
    // Login View
    static let authentication = "authentication"
    static let signInDescription = "sign_in_description"
    static let openingBrowser = "opening_browser"
    static let signInKeycloak = "sign_in_keycloak"
    static let copyright = "copyright"

    // Profile View
    static let welcome = "welcome"
    static let signOut = "sign_out"
    static let language = "language"

    // Tab Bar
    static let downloads = "downloads"
    static let signIn = "sign_in"
    static let profile = "profile"
    static let customers = "customers"

    // Downloads View
    static let downloadsDescription = "downloads_description"
    static let documents = "documents"
    static let videos = "videos"

    // Customers View
    static let customersDescription = "customers_description"
}
