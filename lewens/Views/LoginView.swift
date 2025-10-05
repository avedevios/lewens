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
    
    var body: some View {
        ZStack {
            // Same gradient background as ContentView
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
            
            VStack(spacing: 40) {
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
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(authManager.isLoading ? localizationManager.localizedString(for: LocalizationKeys.openingBrowser) : localizationManager.localizedString(for: LocalizationKeys.signInKeycloak))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green)
                    .foregroundColor(.white)
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
