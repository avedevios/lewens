//
//  DownloadsView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct DownloadsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showLanguagePicker = false
    @ObservedObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        ZStack {
            // Unified app background
            AppBackground()
            
            VStack {
                // Logo header
                LogoHeader(
                    showLanguageButton: false,
                    showLanguagePicker: $showLanguagePicker,
                    languageManager: languageManager,
                    localizationManager: localizationManager
                )
                
                Spacer()
                
                // Title
                LocalizedText(LocalizationKeys.downloads)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                LocalizedText(LocalizationKeys.downloadsDescription)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}

#Preview {
    DownloadsView()
}
