//
//  CookBookApp.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI
import MapKit

@main
struct CookBookApp: App {
    var body: some Scene {
        WindowGroup {
            let recipes = [Recipe]()
            ContentView(recipes: recipes)
                .preferredColorScheme(.light)
        }
    }
}
