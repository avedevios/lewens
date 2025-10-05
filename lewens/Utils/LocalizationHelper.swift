//
//  LocalizationHelper.swift
//  lewens
//
//  Created by Kiro on 2025-10-05.
//

import Foundation

extension String {
    /// Returns localized string for the current key using LanguageManager
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    /// Returns localized string with arguments
    func localized(with arguments: CVarArg...) -> String {
        let localizedString = LocalizationManager.shared.localizedString(for: self)
        return String(format: localizedString, arguments: arguments)
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String = "de" {
        didSet {
            loadCurrentBundle()
        }
    }
    
    private var bundle: Bundle = Bundle.main
    
    private init() {
        loadCurrentBundle()
    }
    
    private func loadCurrentBundle() {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            self.bundle = Bundle.main
            return
        }
        self.bundle = bundle
    }
    
    func localizedString(for key: String) -> String {
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
    
    func setLanguage(_ languageCode: String) {
        currentLanguage = languageCode
        UserDefaults.standard.set(languageCode, forKey: "AppLanguage")
        UserDefaults.standard.synchronize()
    }
}

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
    
    // Customers View
    static let customersDescription = "customers_description"
}