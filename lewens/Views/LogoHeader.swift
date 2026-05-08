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
        HStack(alignment: .center, spacing: 12) {
            Image("LewensLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 11)

            Spacer()

            if showLanguageButton {
                ThemeToggleButton()

                Button(action: { showLanguagePicker = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                        Text(localizationManager.getLanguageName(for: localizationManager.currentLanguage))
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.lssPrimaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.lssSurface)
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
            }
        }
        .frame(height: 60)
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

struct ThemeToggleButton: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Button(action: { themeManager.toggleTheme() }) {
            Image(systemName: themeManager.currentTheme.iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.lssPrimaryText)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(Color.lssSurface)
                )
        }
        .accessibilityLabel(localizationManager.localizedString(for: themeManager.currentTheme.localizationKey))
    }
}

#Preview {
    LogoHeader(
        showLanguageButton: true,
        showLanguagePicker: .constant(false)
    )
    .environmentObject(LocalizationManager.shared)
    .environmentObject(ThemeManager.shared)
    .background(Color.lssBackgroundTop)
}
