//
//  LoginView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var keycloakService: KeycloakService
    @EnvironmentObject private var localizationManager: LocalizationManager

    @State private var showLanguagePicker = false

    var body: some View {
        AppScreen(
            showLanguageButton: true,
            showLanguagePicker: $showLanguagePicker,
            spacing: 40
        ) {
            LocalizedText(LocalizationKeys.authentication)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.lssPrimaryText)

            if let errorMessage = keycloakService.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button(action: {
                keycloakService.login()
            }) {
                HStack {
                    if keycloakService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .lssAnthrazit))
                    }
                    Text(keycloakService.isLoading
                         ? localizationManager.localizedString(for: LocalizationKeys.openingBrowser)
                         : localizationManager.localizedString(for: LocalizationKeys.signIn))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.lssGelb)
                .foregroundColor(.lssAnthrazit)
                .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .disabled(keycloakService.isLoading)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(KeycloakService.shared)
        .environmentObject(LocalizationManager.shared)
        .environmentObject(ThemeManager.shared)
}
