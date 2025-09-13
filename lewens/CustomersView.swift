//
//  CustomersView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct CustomersView: View {
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
                Text("Customers")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Customer list will appear here")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}

#Preview {
    CustomersView()
}
