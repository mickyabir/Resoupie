//
//  CookBookApp.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import UIKit
import SwiftUI
import MapKit

@main
struct CookBookApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .setTheme(LightTheme.self)
        }
    }
}
