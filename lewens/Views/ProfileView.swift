//
//  ProfileView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showLanguagePicker = false
    
    var body: some View {
        ZStack {
            // Same gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.teal,
                    Color.cyan,
                    Color.mint
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo
                Image("LewensLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 200, maxHeight: 100)
                
                // User information
                if let user = authManager.currentUser {
                    VStack(spacing: 15) {
                        LocalizedText(LocalizationKeys.welcome)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(user.displayName)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(user.email)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.3))
                    )
                }
                
                // Buttons
                VStack(spacing: 15) {
                    // Language picker button
                    Button(action: {
                        showLanguagePicker = true
                    }) {
                        HStack {
                            Text(localizationManager.localizedString(for: LocalizationKeys.language))
                            Spacer()
                            Text(languageManager.getLanguageName(for: languageManager.currentLanguage))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2))
                        )
                    }
                    .actionSheet(isPresented: $showLanguagePicker) {
                        ActionSheet(
                            title: Text(localizationManager.localizedString(for: LocalizationKeys.language)),
                            buttons: languageManager.supportedLanguages.map { code, name in
                                .default(Text(name)) {
                                    languageManager.currentLanguage = code
                                }
                            } + [.cancel()]
                        )
                    }
                    

                    
                    // Logout button
                    Button(action: {
                        authManager.logout()
                    }) {
                        LocalizedText(LocalizationKeys.signOut)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
                            )
                    }
                    
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Copyright text - bottom
                LocalizedText(LocalizationKeys.copyright)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    ProfileView()
}
