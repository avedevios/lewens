//
//  CustomersView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct CustomersView: View {
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
                LocalizedText(LocalizationKeys.customers)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.lssAnthrazit)
                
                LocalizedText(LocalizationKeys.customersDescription)
                    .font(.system(size: 16))
                    .foregroundColor(.lssAnthrazit.opacity(0.7))
                    .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}

#Preview {
    CustomersView()
}
