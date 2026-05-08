//
//  ContentView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var keycloakService: KeycloakService
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var selectedTab = 1

    var body: some View {
        TabView(selection: $selectedTab) {
            DownloadsView()
                .tabItem {
                    Image(systemName: "arrow.down.circle")
                    Text(localizationManager.localizedString(for: LocalizationKeys.downloads))
                }
                .tag(0)

            Group {
                if keycloakService.isAuthenticated {
                    ProfileView()
                } else {
                    LoginView()
                }
            }
            .tabItem {
                Image(systemName: keycloakService.isAuthenticated ? "person.circle.fill" : "person.circle")
                Text(keycloakService.isAuthenticated
                     ? localizationManager.localizedString(for: LocalizationKeys.profile)
                     : localizationManager.localizedString(for: LocalizationKeys.signIn))
            }
            .tag(1)

            CustomersListView()
                .tabItem {
                    Image(systemName: "person.2.circle")
                    Text(localizationManager.localizedString(for: LocalizationKeys.customers))
                }
                .tag(2)
        }
        .accentColor(.lssGelb)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
    }
}

#Preview {
    ContentView()
        .environmentObject(KeycloakService.shared)
        .environmentObject(DownloadsService.shared)
        .environmentObject(LocalizationManager.shared)
        .environmentObject(ThemeManager.shared)
}
