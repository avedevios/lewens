//
//  AppScreen.swift
//  lewens
//
//  Shared screen chrome for app views that use the branded background, header, and footer.
//

import SwiftUI

struct AppScreen<Content: View>: View {
    var showLanguageButton: Bool = false
    var spacing: CGFloat = 8

    @Binding private var showLanguagePicker: Bool
    private let content: Content

    init(
        showLanguageButton: Bool = false,
        showLanguagePicker: Binding<Bool>,
        spacing: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.showLanguageButton = showLanguageButton
        self.spacing = spacing
        self._showLanguagePicker = showLanguagePicker
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: spacing) {
                LogoHeader(
                    showLanguageButton: showLanguageButton,
                    showLanguagePicker: $showLanguagePicker
                )

                Spacer()

                content

                Spacer()

                AppFooter()
            }
        }
    }
}

private struct AppFooter: View {
    var body: some View {
        LocalizedText(LocalizationKeys.copyright)
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(.lssMutedText)
            .padding(.bottom, 20)
    }
}

#Preview {
    AppScreen(
        showLanguageButton: true,
        showLanguagePicker: .constant(false),
        spacing: 24
    ) {
        Text("Preview")
            .foregroundColor(.lssPrimaryText)
    }
    .environmentObject(LocalizationManager.shared)
    .environmentObject(ThemeManager.shared)
}
