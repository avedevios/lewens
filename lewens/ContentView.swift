//
//  ContentView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct ContentView: View {
    @State private var downloadsPressed = false
    @State private var customersPressed = false
    
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
            
            // Lewens logo - centered on entire screen
            Image("LewensLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 600, maxHeight: 300)
            
            // Bottom half content
            VStack {
                Spacer()
                
                // Buttons - centered in bottom half
                VStack(spacing: 20) {
                    ZStack {
                        // Shadow effect
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.2))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .offset(y: 8)
                            .blur(radius: 8)
                        
                        // Button
                        Button(action: {
                            // Downloads action
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }) {
                            Text("Downloads")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.black.opacity(0.4),
                                            Color.black.opacity(0.2)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .scaleEffect(downloadsPressed ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: downloadsPressed)
                        .onTapGesture {
                            downloadsPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                downloadsPressed = false
                            }
                        }
                    }
                    
                    ZStack {
                        // Shadow effect
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.2))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .offset(y: 8)
                            .blur(radius: 8)
                        
                        // Button
                        Button(action: {
                            // Customers action
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }) {
                            Text("Customers")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.black.opacity(0.4),
                                            Color.black.opacity(0.2)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .scaleEffect(customersPressed ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: customersPressed)
                        .onTapGesture {
                            customersPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                customersPressed = false
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
                .offset(y: UIScreen.main.bounds.height / 4) // Move to center of bottom half
                
                Spacer()
                
                // Copyright text - bottom
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
