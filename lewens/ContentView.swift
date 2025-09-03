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
            // Фоновое изображение
            Image("BackgroundGradient")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // Логотип Lewens
            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Text("L")
                        .font(.system(size: 48, weight: .bold, design: .default))
                        .foregroundColor(.green)
                    
                    Text("e")
                        .font(.system(size: 48, weight: .bold, design: .default))
                        .foregroundColor(.green)
                        .overlay(
                            // Оранжевый полукруг над 'e'
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 20, height: 20)
                                .offset(y: -15)
                                .clipped()
                        )
                    
                    Text("wens")
                        .font(.system(size: 48, weight: .bold, design: .default))
                        .foregroundColor(.green)
                }
                
                Text("MARKISEN")
                    .font(.system(size: 24, weight: .medium, design: .default))
                    .foregroundColor(.purple.opacity(0.7))
            }
        }
    }
}

#Preview {
    ContentView()
}
