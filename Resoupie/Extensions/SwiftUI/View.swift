//
//  View.swift
//  Resoupie
//
//  Created by Michael Abir on 2/26/22.
//

import SwiftUI

fileprivate struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

fileprivate struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

fileprivate struct ScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    func readScroll(onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: ScrollPreferenceKey.self, value: geometryProxy.frame(in: .global).minY)
            }
        )
        .onPreferenceChange(ScrollPreferenceKey.self, perform: onChange)
    }
}

extension View {
    func setTheme(_ theme: ThemeStyle.Type) -> some View {
                let navigationAppearance = UINavigationBarAppearance()
        
                Color.theme = theme
        
//                if let background = Color.theme.navbarBackground {
//                    navigationAppearance.configureWithOpaqueBackground()
//                    navigationAppearance.backgroundColor = UIColor(background)
//                } else {
//                    navigationAppearance.configureWithDefaultBackground()
//        //            navigationAppearance.configureWithTransparentBackground()
//                }
        
                navigationAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        
                if let titleColor = Color.theme.navbarTitle {
                    navigationAppearance.titleTextAttributes = [.foregroundColor: UIColor(titleColor)]
                    navigationAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(titleColor)]
                }
        
                UINavigationBar.appearance().standardAppearance = navigationAppearance
                UINavigationBar.appearance().compactAppearance = navigationAppearance
                UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        
                // Needed until disappearing tabbar bug is fixed
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                UITabBar.appearance().standardAppearance = tabBarAppearance
        
                UINavigationBar.appearance().tintColor = UIColor(Color.theme.navbarTint)
                UINavigationBar.appearance().isTranslucent = true
        
                UIView.appearance().tintColor = UIColor(Color.theme.tint)
        
        return self
    }
}
