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
            LocalizationManager.shared.setLanguage(currentLanguage)
            saveLanguageForCurrentUser()
        }
    }
    
    let supportedLanguages = [
        "de": "Deutsch",
        "en": "English", 
        "pl": "Polski"
    ]
    
    private var currentUserId: String?
    
    private init() {
        // Start with default language
        self.currentLanguage = Self.getDefaultLanguage()
        LocalizationManager.shared.setLanguage(currentLanguage)
        
        // Listen for authentication changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogin),
            name: .userDidLogin,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogout),
            name: .userDidLogout,
            object: nil
        )
    }
    
    private static func getDefaultLanguage() -> String {
        let supportedLanguages = [
            "de": "Deutsch",
            "en": "English", 
            "pl": "Polski"
        ]
        
        // Get system preferred languages
        let preferredLanguages = Locale.preferredLanguages
        
        for languageCode in preferredLanguages {
            // Extract language code (e.g., "en-US" -> "en")
            let code = String(languageCode.prefix(2))
            
            // Check if we support this language
            if supportedLanguages.keys.contains(code) {
                return code
            }
        }
        
        // Fallback to German if no supported language found
        return "de"
    }
    
    @objc private func userDidLogin(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let user = userInfo["user"] as? User else { 
            return 
        }
        
        // Set currentUserId FIRST, before loading language
        currentUserId = user.id
        
        // Now load the language for this user
        loadLanguageForUser(userId: user.id)
    }
    
    @objc private func userDidLogout(_ notification: Notification) {
        currentUserId = nil
        // Reset to default language when user logs out
        currentLanguage = Self.getDefaultLanguage()
    }
    
    private func loadLanguageForUser(userId: String) {
        let key = "AppLanguage_\(userId)"
        let savedValue = UserDefaults.standard.string(forKey: key)
        
        // Check if the saved value is a valid language code
        if let savedLanguage = savedValue, supportedLanguages.keys.contains(savedLanguage) {
            setLanguageWithoutSaving(savedLanguage)
        } else {
            // No saved language or invalid language code - use default
            let defaultLang = Self.getDefaultLanguage()
            setLanguageWithoutSaving(defaultLang)
        }
    }
    
    private func setLanguageWithoutSaving(_ language: String) {
        // Temporarily disable saving by clearing currentUserId
        let tempUserId = currentUserId
        currentUserId = nil
        
        // Set the language (this will trigger didSet but won't save because currentUserId is nil)
        currentLanguage = language
        LocalizationManager.shared.setLanguage(language)
        
        // Restore currentUserId
        currentUserId = tempUserId
    }
    
    private func saveLanguageForCurrentUser() {
        guard let userId = currentUserId else { 
            return 
        }
        let key = "AppLanguage_\(userId)"
        UserDefaults.standard.set(currentLanguage, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getLanguageName(for code: String) -> String {
        return supportedLanguages[code] ?? code
    }
    

}