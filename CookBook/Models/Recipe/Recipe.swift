//
//  Recipe.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import Foundation
import MapKit

struct Recipe: Hashable, Codable {
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
}
