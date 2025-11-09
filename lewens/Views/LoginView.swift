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
            // LSS brand gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.lssAnthrazit,
                    Color.lssAnthrazit.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Language button - top right
                HStack {
                    Spacer()
                    Button(action: {
                        showLanguagePicker = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "globe")
                            Text(languageManager.getLanguageName(for: languageManager.currentLanguage))
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Logo
                Image("LewensLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300, maxHeight: 150)
                
                // Title
                LocalizedText(LocalizationKeys.authentication)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // Description
                LocalizedText(LocalizationKeys.signInDescription)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
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
                        Text(authManager.isLoading ? localizationManager.localizedString(for: LocalizationKeys.openingBrowser) : localizationManager.localizedString(for: LocalizationKeys.signInKeycloak))
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
