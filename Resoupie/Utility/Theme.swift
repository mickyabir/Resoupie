//
//  Colors.swift
//  Resoupie
//
//  Created by Michael Abir on 2/3/22.
//

import SwiftUI

protocol ThemeStyle {
    static var background: Color { get }
    static var text: Color { get }
    static var lightText: Color { get }
    static var title: Color { get }
    static var title2: Color { get }
    static var title3: Color { get }
    static var headline: Color { get }
    static var accent: Color { get }
    static var tint: Color { get }
    static var navbarTitle: Color? { get }
    static var navbarTint: Color { get }
    static var navbarBackground: Color? { get }
    static var light: Color { get }
    static var red: Color { get }
}

struct LightTheme: ThemeStyle {
    static var accent = Color.orange
    static var tint = Color.orange
    static let background = Color(uiColor: UIColor.systemGray6)
    static let text = Color(red: 105 / 255, green: 84 / 255, blue: 70 / 255)
    static let lightText = Color(red: 153 / 255, green: 136 / 255, blue: 124 / 255)
    static let title = Color(red: 125 / 255, green: 104 / 255, blue: 90 / 255)
    static let title2 = title
    static let title3 = title
    static let headline = title
    static let navbarTint: Color = Color.orange
    static let navbarTitle: Color? = Color(red: 105 / 255, green: 84 / 255, blue: 70 / 255)
    static let navbarBackground: Color? = nil
    static let light = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
    static let red = Color.red
}
