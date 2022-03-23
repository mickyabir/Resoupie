//
//  Recipe.swift
//  Resoupie
//
//  Created by Michael Abir on 1/18/22.
//

import Foundation
import MapKit

struct Recipe: Hashable, Codable {
    var about: String
    var image: String
    var name: String
    var ingredients: [Ingredient]
    var steps: [String]
    var coordinate_lat: Double?
    var coordinate_long: Double?
    var emoji: String
    var servings: Int
    var tags: [String]
    var time: String
    var specialTools: [String]
    var parent_id: String?
    
    func coordinate() -> CLLocationCoordinate2D? {
        if let lat = coordinate_lat, let long = coordinate_long {
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        return nil
    }
    
    func childOf(parent_id: String) -> Recipe {
        var child = self
        child.parent_id = parent_id
        return child
    }
}

extension Recipe {
    static var empty: Recipe {
        get {
            Recipe(about: "", image: "", name: "", ingredients: [], steps: [], coordinate_lat: nil, coordinate_long: nil, emoji: "", servings: 0, tags: [], time: "", specialTools: [], parent_id: nil)
        }
    }
}
