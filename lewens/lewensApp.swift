//
//  lewensApp.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

@main
struct lewensApp: App {
    
    init() {
        // Initialize localization lazily to improve startup time
        // Localization will be initialized when first accessed
        
        #if DEBUG
        StartupProfiler.shared.recordMilestone("App Init Started")
        #endif
    }
    
        var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    // Handle OAuth callback
                    handleOAuthCallback(url: url)
                }
        }
    }
    
    // Handle OAuth callback from Keycloak
    private func handleOAuthCallback(url: URL) {
        // Check if this is our OAuth callback
        if url.scheme == "lewens" && url.host == "auth" {
            // Notify KeycloakService about the callback
            KeycloakService.shared.handleOAuthCallback(url: url)
        }
    }
}
