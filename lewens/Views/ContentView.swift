//
//  ContentView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1 // Start with center tab (Sign In)
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Downloads - left tab
            DownloadsView()
                .tabItem {
                    Image(systemName: "arrow.down.circle")
                    Text(localizationManager.localizedString(for: LocalizationKeys.downloads))
                }
                .tag(0)
            
            // Login/Profile - center tab
            Group {
                if authManager.isAuthenticated {
                    ProfileView()
                } else {
                    LoginView()
                }
            }
            .tabItem {
                Image(systemName: authManager.isAuthenticated ? "person.circle.fill" : "person.circle")
                Text(authManager.isAuthenticated ? localizationManager.localizedString(for: LocalizationKeys.profile) : localizationManager.localizedString(for: LocalizationKeys.signIn))
            }
            .tag(1)
            
            // Customers - right tab
            CustomersView()
                .tabItem {
                    Image(systemName: "person.2.circle")
                    Text(localizationManager.localizedString(for: LocalizationKeys.customers))
                }
                .tag(2)
        }
        .accentColor(.white) // Active tab color
    }
}

#Preview {
    ContentView()
}
