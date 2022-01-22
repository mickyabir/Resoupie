//
//  ContentView.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

struct ContentView: View {
    var recipes: [Recipe]
    @AppStorage("favorites") var favorites: [Recipe] = []
    
    var body: some View {
        TabView {
            WorldView()
                .tabItem {
                    Label("World", systemImage: "map")
                }
            
            RecipesMainView(recipes: recipes)
                .tabItem {
                    Label("Recipes", systemImage: "globe")
                }
            
            FavoritesView(favorites: favorites)
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }

            GroceriesView()
                .tabItem {
                    Label("Groceries", systemImage: "checklist")
                }
        }
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let ingredients = [
            Ingredient(id: 0, name: "milk", quantity: "2", unit: "cup"),
            Ingredient(id: 1, name: "tea", quantity: "1/2", unit: "cup"),
            Ingredient(id: 2, name: "sugar", quantity: "2", unit: "tblsp")
        ]
        let steps = [
            "Mix sugar and tea",
            "Add milk"
        ]
        let boba_recipe = Recipe(id: UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e")!, name: "boba", author: "Micky Abir", rating: 4.5, ingredients: ingredients, steps: steps)
        let recipes = [boba_recipe]
        ContentView(recipes: recipes, favorites: recipes)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
