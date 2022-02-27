//
//  Colors.swift
//  CookBook
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
    static var accent: Color { get }
    static var navbarTitle: Color? { get }
    static var navbarTint: Color? { get }
    static var navbarBackground: Color? { get }
}

struct LightTheme: ThemeStyle {
    static var accent = Color.orange
    static let background = Color(red: 250 / 255, green: 252 / 255, blue: 255 / 255)
    static let text = Color(red: 105 / 255, green: 84 / 255, blue: 70 / 255)
    static let lightText = Color(red: 153 / 255, green: 136 / 255, blue: 124 / 255)
    static let title = Color(red: 125 / 255, green: 104 / 255, blue: 90 / 255)
    static let title2 = title
    static let title3 = title
    static let navbarTint: Color? = nil
    static let navbarTitle: Color? = Color(red: 105 / 255, green: 84 / 255, blue: 70 / 255)
    static let navbarBackground: Color? = nil
}
