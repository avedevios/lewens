//
//  DownloadsView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct DownloadsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        ZStack {
            // Same gradient background
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
            
            VStack {
                Spacer()
                
                // Logo
                Image("LewensLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300, maxHeight: 150)
                
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
