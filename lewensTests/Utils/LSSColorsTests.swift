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

    // MARK: - RGB regression (UIColor bridge)

    private func components(of color: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        let ui = UIColor(color)
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
