//
//  LanguageManager.swift
//  lewens
//
//  Created by Kiro on 2025-10-05.
//

import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: String {
        didSet {
            // Sync with LocalizationManager when language changes
            LocalizationManager.shared.setLanguage(currentLanguage)
            saveLanguage()
        }
    }
    
    let supportedLanguages = [
        "de": "Deutsch",
        "en": "English", 
        "pl": "Polski"
    ]
    
    private init() {
    // Load saved language or use default
    self.currentLanguage = Self.loadSavedLanguage()

    // Property observers (didSet) are NOT called when a property is set during
    // initialization. That means the LocalizationManager won't be synced here.
    // Explicitly sync the LocalizationManager so the saved language is applied
    // on startup.
    DispatchQueue.main.async {
        LocalizationManager.shared.setLanguage(self.currentLanguage)
    }
    }
    
    private static func loadSavedLanguage() -> String {
        // Check if there's a saved language
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage"),
           ["de", "en", "pl"].contains(savedLanguage) {
            return savedLanguage
        }
        
        // Otherwise use system default
        return getDefaultLanguage()
    }
    
    private static func getDefaultLanguage() -> String {
        // Get system preferred languages
        let preferredLanguages = Locale.preferredLanguages
        let supportedCodes = ["de", "en", "pl"]
        
        for languageCode in preferredLanguages {
            // Extract language code (e.g., "en-US" -> "en")
            let code = String(languageCode.prefix(2))
            
            // Check if we support this language
            if supportedCodes.contains(code) {
                return code
            }
        }
        
        // Fallback to German if no supported language found
        return "de"
    }
    
    private func saveLanguage() {
        UserDefaults.standard.set(currentLanguage, forKey: "AppLanguage")
    }
    
    func getLanguageName(for code: String) -> String {
        return supportedLanguages[code] ?? code
    }
}