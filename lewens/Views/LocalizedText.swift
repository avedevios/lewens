//
//  LocalizedText.swift
//  lewens
//

import SwiftUI

/// A Text view that automatically uses the current app language via LocalizationManager.
/// Supports all native SwiftUI Text modifiers since it wraps Text directly.
struct LocalizedText: View {
    let key: String
    @EnvironmentObject private var localizationManager: LocalizationManager

    init(_ key: String) {
        self.key = key
    }

    var body: some View {
        Text(localizationManager.localizedString(for: key))
    }
}
