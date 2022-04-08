//
//  RecipeMeta.swift
//  Resoupie
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
    var views: Int
    var cooked: Int
}

extension RecipeMeta {
    func contains(_ searchText: String) -> Bool {
        let searchText = searchText.lowercased()
        return author.lowercased().contains(searchText) || recipe.name.lowercased().contains(searchText) || !recipe.ingredientsSections.compactMap({ $0.ingredients }).reduce([], +).filter({ $0.name.lowercased().contains(searchText) }).isEmpty || !recipe.specialTools.filter({ $0.lowercased().contains(searchText) }).isEmpty || !recipe.specialTools.filter({ $0.lowercased().contains(searchText) }).isEmpty
    }
    
    func childOf(parent_id: String) -> RecipeMeta {
        var child = self
        child.recipe = child.recipe.childOf(parent_id: parent_id)
        return child
    }

}

extension RecipeMeta {
    static var empty: RecipeMeta {
        get {
            RecipeMeta(id: "", author: "", user_id: "", recipe: Recipe.empty, rating: 0, favorited: 0, views: 0, cooked: 0)
        }
    }
}
