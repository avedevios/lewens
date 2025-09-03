//
//  ContentView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct ContentView: View {
    let navigationTypes = [
        "Stack", "Tabs", "Sheet", "Sidebar", "Split",
        "Pages", "Grid", "Carousel", "Bottom", "Custom"
    ]
    
    @State private var tappedItem: String? = nil
    
    var body: some View {
        ZStack {
            // Background image
            Image("BackgroundGradient")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .ignoresSafeArea()
            
            // Content layout
            VStack(spacing: 0) {
                // Top half - empty for background
                Spacer()
                
                // Bottom half - grid
                VStack {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(navigationTypes, id: \.self) { navigationType in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 80)
                                .overlay(
                                    Text(navigationType)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .medium))
                                )
                                .scaleEffect(tappedItem == navigationType ? 0.95 : 1.0)
                                .animation(.easeInOut(duration: 0.1), value: tappedItem)
                                .onTapGesture {
                                    tappedItem = navigationType
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    
                                    // Reset after animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        tappedItem = nil
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .frame(maxHeight: UIScreen.main.bounds.height / 2)
            }
        }
    }
}

#Preview {
    ContentView()
}
