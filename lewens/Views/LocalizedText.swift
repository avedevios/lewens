//
//  LocalizedText.swift
//  lewens
//
//  Created by Kiro on 2025-10-05.
//

import SwiftUI

struct LocalizedText: View {
    let key: String
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    init(_ key: String) {
        self.key = key
    }
    
    var body: some View {
        Text(localizationManager.localizedString(for: key))
    }
}

// Extension for easier usage
extension LocalizedText {
    func font(_ font: Font) -> some View {
        self.modifier(FontModifier(font: font))
    }
    
    func foregroundColor(_ color: Color) -> some View {
        self.modifier(ForegroundColorModifier(color: color))
    }
    
    func multilineTextAlignment(_ alignment: TextAlignment) -> some View {
        self.modifier(MultilineTextAlignmentModifier(alignment: alignment))
    }
}

struct FontModifier: ViewModifier {
    let font: Font
    
    func body(content: Content) -> some View {
        content.font(font)
    }
}

struct ForegroundColorModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content.foregroundColor(color)
    }
}

struct MultilineTextAlignmentModifier: ViewModifier {
    let alignment: TextAlignment
    
    func body(content: Content) -> some View {
        content.multilineTextAlignment(alignment)
    }
}