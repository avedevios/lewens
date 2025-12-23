//
//  LoginView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var showLanguagePicker = false
    
    var body: some View {
        ZStack {
            // Unified app background
            AppBackground()
            
            VStack(spacing: 40) {
                // Logo header with language button
                LogoHeader(
                    showLanguageButton: true,
                    showLanguagePicker: $showLanguagePicker,
                    languageManager: languageManager,
                    localizationManager: localizationManager
                )
                
                Spacer()
                
                // Title
                LocalizedText(LocalizationKeys.authentication)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // Error message
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Login button
                Button(action: {
                    authManager.login(email: "", password: "")
                }) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .lssAnthrazit))
                        }
                        Text(authManager.isLoading ? localizationManager.localizedString(for: LocalizationKeys.openingBrowser) : localizationManager.localizedString(for: LocalizationKeys.signIn))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.lssGelb)
                    .foregroundColor(.lssAnthrazit)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .disabled(authManager.isLoading)
                
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
    LoginView()
}
