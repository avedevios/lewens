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
            // Unified app background
            AppBackground()
            
            VStack(spacing: 30) {
                // Logo header with language button
                LogoHeader(
                    showLanguageButton: true,
                    showLanguagePicker: $showLanguagePicker,
                    languageManager: languageManager,
                    localizationManager: localizationManager
                )
                
                Spacer()
                
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
                            .fill(Color.white.opacity(0.1))
                    )
                }
                
                // Buttons
                VStack(spacing: 15) {
                    // Logout button
                    Button(action: {
                        authManager.logout()
                    }) {
                        LocalizedText(LocalizationKeys.signOut)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.lssAnthrazit)
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
