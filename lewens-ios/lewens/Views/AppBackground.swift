//
//  AppBackground.swift
//  lewens
//
//  Unified background component for consistent styling across all views
//

import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.lssAnthrazit,
                Color.lssAnthrazit.opacity(0.95)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    AppBackground()
}
