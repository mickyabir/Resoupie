//
//  Recipe.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import Foundation

struct Ingredient: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var quantity: String
    var unit: String
}

struct Recipe: Hashable, Codable, Identifiable {
    var id: UUID
    var name: String
    var author: String
    var rating: Double
    var ingredients: [Ingredient]
    var steps: [String]
}
