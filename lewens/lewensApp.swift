//
//  lewensApp.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

@main
struct lewensApp: App {

    // Single source of truth — injected into the view hierarchy via EnvironmentObject
    private let keycloakService = KeycloakService.shared
    private let downloadsService = DownloadsService.shared
    private let localizationManager = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(keycloakService)
                .environmentObject(downloadsService)
                .environmentObject(localizationManager)
                .onOpenURL { url in
                    if url.scheme == "lewens" && url.host == "auth" {
                        keycloakService.handleOAuthCallback(url: url)
                    }
                }
        }
    }
}
