//
//  LogoHeader.swift
//  lewens
//
//  Unified logo header component for consistent positioning across all views

import SwiftUI

struct LogoHeader: View {
    var showLanguageButton: Bool = false
    @Binding var showLanguagePicker: Bool
    @ObservedObject var languageManager: LanguageManager
    @ObservedObject var localizationManager: LocalizationManager
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Logo - top left with size matching language button
            Image("LewensLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 11)
            
            Spacer()
            
            // Language button - top right (optional)
            if showLanguageButton {
                Button(action: {
                    showLanguagePicker = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                        Text(languageManager.getLanguageName(for: languageManager.currentLanguage))
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
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
            } else {
                // Invisible placeholder to keep layout consistent
                Color.clear
                    .frame(width: 100, height: 32)
            }
        }
        .frame(height: 60)
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

#Preview {
    LogoHeader(
        showLanguageButton: true,
        showLanguagePicker: .constant(false),
        languageManager: LanguageManager.shared,
        localizationManager: LocalizationManager.shared
    )
    .background(Color.lssAnthrazit)
}
