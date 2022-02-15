//
//  Recipe.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import Foundation
import MapKit
import SwiftUI

struct Ingredient: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var quantity: String
    var unit: String
}

struct Recipe: Hashable, Codable, Identifiable {
    var id: UUID
    var image: String
    var name: String
    var author: String
    var ingredients: [Ingredient]
    var steps: [String]
    var coordinate: CLLocationCoordinate2D?
    var emoji: String
    var servings: Int
    var tags: [String]
    var time: String
    var specialTools: [String]
}

struct RecipeMeta: Hashable, Codable, Identifiable {
    var id: UUID
    var recipe: Recipe
    var rating: Double
    var favorited: Int
    
    init(recipe: Recipe, rating: Double, favorited: Int) {
        self.recipe = recipe
        self.rating = rating
        self.favorited = favorited
        id = recipe.id
    }
}

extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
     
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}
