//
//  ContentView.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

struct ContentView: View {
    var recipes: [Recipe]
    
    var body: some View {
        TabView {
            WorldView()
                .tabItem {
                    Label("World", systemImage: "globe")
                }
            
            RecipesMainView(recipes: recipes)
                .tabItem {
                    Label("Recipes", systemImage: "globe")
                }
            
            FavoritesView()
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
        let boba_recipe = Recipe(id: UUID(), name: "boba", author: "Micky Abir", rating: 4.5, ingredients: ingredients, steps: steps)
        let recipes = [boba_recipe]
        ContentView(recipes: recipes)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
