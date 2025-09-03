//
//  ContentView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Gradient background - better contrast for MARKISEN
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
            
            // Lewens logo - centered
            Image("LewensLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 600, maxHeight: 300)
            
            // Copyright text - bottom
            VStack {
                Spacer()
                Text("© 2025 AVE Software. All rights reserved.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    ContentView()
}
