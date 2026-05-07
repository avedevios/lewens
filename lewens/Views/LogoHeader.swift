//
//  LogoHeader.swift
//  lewens
//
//  Unified logo header component for consistent positioning across all views.

import SwiftUI

struct LogoHeader: View {
    var showLanguageButton: Bool = false
    @Binding var showLanguagePicker: Bool
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image("LewensLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 11)

            Spacer()

            if showLanguageButton {
                Button(action: { showLanguagePicker = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                        Text(localizationManager.getLanguageName(for: localizationManager.currentLanguage))
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
                .confirmationDialog(
                    localizationManager.localizedString(for: LocalizationKeys.language),
                    isPresented: $showLanguagePicker
                ) {
                    ForEach(
                        localizationManager.supportedLanguages.sorted(by: { $0.key < $1.key }),
                        id: \.key
                    ) { code, name in
                        Button(name) {
                            localizationManager.currentLanguage = code
                        }
                    }
                }
            } else {
                Color.clear.frame(width: 100, height: 32)
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
        showLanguagePicker: .constant(false)
    )
    .environmentObject(LocalizationManager.shared)
    .background(Color.lssAnthrazit)
}
