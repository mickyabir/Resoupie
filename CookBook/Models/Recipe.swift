//
//  Recipe.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import Foundation
import MapKit

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
    var rating: Double
    var ingredients: [Ingredient]
    var steps: [String]
    var coordinate: CLLocationCoordinate2D?
    var emoji: String
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