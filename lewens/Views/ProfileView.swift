//
//  ProfileView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var keycloakService: KeycloakService
    @EnvironmentObject private var localizationManager: LocalizationManager

    @State private var showLanguagePicker = false

    var body: some View {
        AppScreen(
            showLanguageButton: true,
            showLanguagePicker: $showLanguagePicker,
            spacing: 30
        ) {
            if let user = keycloakService.currentUser {
                VStack(spacing: 15) {
                    LocalizedText(LocalizationKeys.welcome)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.lssPrimaryText)

                    Text(user.displayName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.lssPrimaryText)

                    Text(user.email)
                        .font(.system(size: 16))
                        .foregroundColor(.lssSecondaryText)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.lssSurface)
                )
            }

            Button(action: {
                keycloakService.logout()
            }) {
                LocalizedText(LocalizationKeys.signOut)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.lssAnthrazit)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.lssGelb)
                    )
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(KeycloakService.shared)
        .environmentObject(LocalizationManager.shared)
        .environmentObject(ThemeManager.shared)
}
