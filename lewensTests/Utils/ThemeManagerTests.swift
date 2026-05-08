//
//  ThemeManagerTests.swift
//  lewensTests
//

import SwiftUI
import Testing
@testable import lewens

@Suite("ThemeManager")
struct ThemeManagerTests {
    @Test("System theme does not force a color scheme")
    func systemThemeUsesSystemColorScheme() {
        #expect(AppTheme.system.colorScheme == nil)
    }

    @Test("Day and night themes force expected color schemes")
    func fixedThemesUseExpectedColorSchemes() {
        #expect(AppTheme.day.colorScheme == .light)
        #expect(AppTheme.night.colorScheme == .dark)
    }

    @Test("Theme toggle cycles through system day and night")
    func themeCycleOrder() {
        #expect(AppTheme.system.next == .day)
        #expect(AppTheme.day.next == .night)
        #expect(AppTheme.night.next == .system)
    }
}
