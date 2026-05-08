//
//  LSSColorsTests.swift
//  lewensTests
//
//  Regression tests for LSS brand colors.
//  These lock in the exact RGB values so accidental changes are caught.
//

import Testing
import SwiftUI
import UIKit
@testable import lewens

@Suite("LSSColors")
struct LSSColorsTests {

    // MARK: - Existence

    @Test("lssAnthrazit is accessible")
    func lssAnthrazitExists() {
        let color = Color.lssAnthrazit
        // If the extension doesn't exist this won't compile
        _ = color
    }

    @Test("lssGelb is accessible")
    func lssGelbExists() {
        _ = Color.lssGelb
    }

    @Test("lssBronze is accessible")
    func lssBronzeExists() {
        _ = Color.lssBronze
    }

    @Test("lssGrau is accessible")
    func lssGrauExists() {
        _ = Color.lssGrau
    }

    @Test("semantic theme colors are accessible")
    func semanticThemeColorsExist() {
        _ = Color.lssBackgroundTop
        _ = Color.lssBackgroundBottom
        _ = Color.lssPrimaryText
        _ = Color.lssSecondaryText
        _ = Color.lssMutedText
        _ = Color.lssSurface
        _ = Color.lssElevatedSurface
        _ = Color.lssOverlay
        _ = Color.lssCodeBackground
    }

    // MARK: - RGB regression (UIColor bridge)

    private func components(
        of color: Color,
        userInterfaceStyle: UIUserInterfaceStyle = .unspecified
    ) -> (r: Double, g: Double, b: Double, a: Double) {
        let traits = UITraitCollection(userInterfaceStyle: userInterfaceStyle)
        let ui = UIColor(color).resolvedColor(with: traits)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b), Double(a))
    }

    @Test("lssAnthrazit has correct RGB values")
    func lssAnthrazitRGB() {
        let c = components(of: .lssAnthrazit)
        #expect(abs(c.r - 46.0/255.0) < 0.01)
        #expect(abs(c.g - 45.0/255.0) < 0.01)
        #expect(abs(c.b - 44.0/255.0) < 0.01)
        #expect(abs(c.a - 1.0)        < 0.01)
    }

    @Test("lssGelb has correct RGB values")
    func lssGelbRGB() {
        let c = components(of: .lssGelb)
        #expect(abs(c.r - 255.0/255.0) < 0.01)
        #expect(abs(c.g - 222.0/255.0) < 0.01)
        #expect(abs(c.b -  19.0/255.0) < 0.01)
        #expect(abs(c.a - 1.0)         < 0.01)
    }

    @Test("lssBronze has correct RGB values")
    func lssBronzeRGB() {
        let c = components(of: .lssBronze)
        #expect(abs(c.r - 216.0/255.0) < 0.01)
        #expect(abs(c.g - 175.0/255.0) < 0.01)
        #expect(abs(c.b - 120.0/255.0) < 0.01)
        #expect(abs(c.a - 1.0)         < 0.01)
    }

    @Test("lssGrau has correct RGB values")
    func lssGrauRGB() {
        let c = components(of: .lssGrau)
        #expect(abs(c.r - 228.0/255.0) < 0.01)
        #expect(abs(c.g - 228.0/255.0) < 0.01)
        #expect(abs(c.b - 216.0/255.0) < 0.01)
        #expect(abs(c.a - 1.0)         < 0.01)
    }

    @Test("Semantic colors resolve differently for day and night themes")
    func semanticColorsResolveForThemes() {
        let dayBackground = components(of: .lssBackgroundTop, userInterfaceStyle: .light)
        let nightBackground = components(of: .lssBackgroundTop, userInterfaceStyle: .dark)
        let backgroundDiff = abs(dayBackground.r - nightBackground.r)
            + abs(dayBackground.g - nightBackground.g)
            + abs(dayBackground.b - nightBackground.b)

        let dayText = components(of: .lssPrimaryText, userInterfaceStyle: .light)
        let nightText = components(of: .lssPrimaryText, userInterfaceStyle: .dark)
        let textDiff = abs(dayText.r - nightText.r)
            + abs(dayText.g - nightText.g)
            + abs(dayText.b - nightText.b)

        #expect(backgroundDiff > 0.5)
        #expect(textDiff > 0.5)
    }

    // MARK: - Distinctness

    @Test("All four brand colors are distinct")
    func colorsAreDistinct() {
        let colors: [Color] = [.lssAnthrazit, .lssGelb, .lssBronze, .lssGrau]
        let components = colors.map { self.components(of: $0) }

        for i in 0..<components.count {
            for j in (i+1)..<components.count {
                let a = components[i]
                let b = components[j]
                let diff = abs(a.r - b.r) + abs(a.g - b.g) + abs(a.b - b.b)
                #expect(diff > 0.05, "Colors at index \(i) and \(j) are too similar")
            }
        }
    }
}
