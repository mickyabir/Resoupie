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

struct Recipe: Hashable, Codable {
    var image: String
    var name: String
    var ingredients: [Ingredient]
    var steps: [String]
    var coordinate: CLLocationCoordinate2D?
    var emoji: String
    var servings: Int
    var tags: [String]
    var time: String
    var specialTools: [String]
    var parent_id: String?
}

struct RecipeMeta: Hashable, Codable, Identifiable {
    var id: String
    var author: String
    var recipe: Recipe
    var rating: Double
    var favorited: Int
    
    init(id: String, author: String, recipe: Recipe, rating: Double, favorited: Int) {
        self.recipe = recipe
        self.rating = rating
        self.favorited = favorited
        self.id = id
        self.author = author
    }
}

extension RecipeMeta {
    func contains(_ searchText: String) -> Bool {
        let searchText = searchText.lowercased()
        return author.lowercased().contains(searchText) || recipe.name.lowercased().contains(searchText) || !recipe.ingredients.filter({ $0.name.lowercased().contains(searchText) }).isEmpty || !recipe.specialTools.filter({ $0.lowercased().contains(searchText) }).isEmpty || !recipe.specialTools.filter({ $0.lowercased().contains(searchText) }).isEmpty
    }
}
