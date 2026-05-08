//
//  LSSColors.swift
//  lewens
//
//  LSS Brand Colors
//

import SwiftUI
import UIKit

extension Color {
    static let lssAnthrazit = Color(red: 46/255, green: 45/255, blue: 44/255)
    static let lssGelb = Color(red: 255/255, green: 222/255, blue: 19/255)
    static let lssBronze = Color(red: 216/255, green: 175/255, blue: 120/255)
    static let lssGrau = Color(red: 228/255, green: 228/255, blue: 216/255)

    static let lssBackgroundTop = Color(dynamicLight: UIColor(red: 246/255, green: 246/255, blue: 240/255, alpha: 1),
                                        dark: UIColor(red: 46/255, green: 45/255, blue: 44/255, alpha: 1))
    static let lssBackgroundBottom = Color(dynamicLight: UIColor(red: 228/255, green: 228/255, blue: 216/255, alpha: 1),
                                           dark: UIColor(red: 39/255, green: 38/255, blue: 37/255, alpha: 1))
    static let lssPrimaryText = Color(dynamicLight: UIColor(red: 46/255, green: 45/255, blue: 44/255, alpha: 1),
                                      dark: .white)
    static let lssSecondaryText = Color(dynamicLight: UIColor(red: 91/255, green: 89/255, blue: 86/255, alpha: 1),
                                        dark: UIColor(white: 1, alpha: 0.78))
    static let lssMutedText = Color(dynamicLight: UIColor(red: 108/255, green: 105/255, blue: 99/255, alpha: 1),
                                    dark: UIColor(white: 1, alpha: 0.68))
    static let lssSurface = Color(dynamicLight: UIColor(white: 1, alpha: 0.72),
                                  dark: UIColor(white: 1, alpha: 0.10))
    static let lssElevatedSurface = Color(dynamicLight: .white,
                                          dark: UIColor(red: 62/255, green: 60/255, blue: 58/255, alpha: 1))
    static let lssOverlay = Color(dynamicLight: UIColor(white: 0, alpha: 0.25),
                                  dark: UIColor(white: 0, alpha: 0.40))
    static let lssCodeBackground = Color(dynamicLight: UIColor(white: 1, alpha: 0.82),
                                         dark: UIColor(white: 0, alpha: 0.50))

    private init(dynamicLight light: UIColor, dark: UIColor) {
        self.init(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
