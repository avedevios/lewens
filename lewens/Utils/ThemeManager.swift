//
//  ThemeManager.swift
//  lewens
//
//  Stores and applies the app appearance preference.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case day
    case night

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .day:
            return .light
        case .night:
            return .dark
        }
    }

    var iconName: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .day:
            return "sun.max.fill"
        case .night:
            return "moon.fill"
        }
    }

    var localizationKey: String {
        switch self {
        case .system:
            return LocalizationKeys.systemTheme
        case .day:
            return LocalizationKeys.dayTheme
        case .night:
            return LocalizationKeys.nightTheme
        }
    }

    var next: AppTheme {
        switch self {
        case .system:
            return .day
        case .day:
            return .night
        case .night:
            return .system
        }
    }
}

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: Self.storageKey)
        }
    }

    private static let storageKey = "AppTheme"

    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: Self.storageKey),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }

    func toggleTheme() {
        currentTheme = currentTheme.next
    }
}
