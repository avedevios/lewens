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
            // LSS brand background
            Color.lssGrau
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
                    .foregroundColor(.lssAnthrazit)
                
                LocalizedText(LocalizationKeys.downloadsDescription)
                    .font(.system(size: 16))
                    .foregroundColor(.lssAnthrazit.opacity(0.7))
                    .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}

#Preview {
    DownloadsView()
}
