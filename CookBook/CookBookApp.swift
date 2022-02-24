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
            let _ = Theme.navigationBarColors(background: nil, titleColor: UIColor(Color.navbarTitle), tintColor: UIColor.orange)
            
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
