//
//  Colors.swift
//  CookBook
//
//  Created by Michael Abir on 2/3/22.
//

import SwiftUI

class Theme {
    static func navigationBarColors(background : UIColor?,
       titleColor : UIColor? = nil, tintColor : UIColor? = nil ){
        
        let navigationAppearance = UINavigationBarAppearance()
        
        if let background = background {
            navigationAppearance.configureWithOpaqueBackground()
            navigationAppearance.backgroundColor = background
        } else {
            navigationAppearance.configureWithDefaultBackground()
//            navigationAppearance.configureWithTransparentBackground()
        }
        
        if let titleColor = titleColor {
            navigationAppearance.titleTextAttributes = [.foregroundColor: titleColor]
            navigationAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
        }
        
        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance

        if let tintColor = tintColor {
            UINavigationBar.appearance().tintColor = tintColor
        }
    }
}

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    static let lightGray = Color(red: 250 / 255, green: 250 / 255, blue: 250 / 255)
    static let background = Color(red: 249 / 255, green: 251 / 255, blue: 255 / 255)
    static let backgroundGradient1 = Color(red: 255 / 255, green: 179 / 255, blue: 138 / 255)
    static let backgroundGradient2 = Color(red: 255 / 255, green: 209 / 255, blue: 181 / 255)
    static let text = Color(red: 105 / 255, green: 84 / 255, blue: 70 / 255)
    static let lightText = Color(red: 153 / 255, green: 136 / 255, blue: 124 / 255)
    static let navbarTitle = Color(red: 105 / 255, green: 84 / 255, blue: 70 / 255)
    static let navbarBackground = Color(red: 255 / 255, green: 159 / 255, blue: 111 / 255)
    static let title = Color(red: 125 / 255, green: 104 / 255, blue: 90 / 255)
    static let title2 = title
    static let title3 = title
}
