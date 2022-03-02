//
//  RecipeMeta.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import Foundation

struct RecipeMeta: Hashable, Codable, Identifiable {
    var id: String
    var author: String
    var user_id: String
    var recipe: Recipe
    var rating: Double
    var favorited: Int
}

extension RecipeMeta {
    func contains(_ searchText: String) -> Bool {
        let searchText = searchText.lowercased()
        return author.lowercased().contains(searchText) || recipe.name.lowercased().contains(searchText) || !recipe.ingredients.filter({ $0.name.lowercased().contains(searchText) }).isEmpty || !recipe.specialTools.filter({ $0.lowercased().contains(searchText) }).isEmpty || !recipe.specialTools.filter({ $0.lowercased().contains(searchText) }).isEmpty
    }
}
