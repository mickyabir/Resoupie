//
//  RecipesMain.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

struct RecipeRow: View {
    var recipe: Recipe
    
    var body: some View {
        HStack {
            Image(recipe.image)
                .resizable()
                .frame(width: 128.0, height: 128.0)
                .cornerRadius(20)
            VStack {
                Text(recipe.name)
                Text("by")
                    .padding(3)
                Text(recipe.author)
            }
        }
    }
}

struct RecipesMainView: View {
    var recipes: [Recipe]
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            List(recipes) { recipe in
                NavigationLink {
                    RecipeDetail(recipe: recipe)
                } label: {
                    RecipeRow(recipe: recipe)
                }
            }
            .navigationTitle("Recipes")
        }
    }
}

struct RecipesMainView_Previews: PreviewProvider {
    static var previews: some View {
        let ingredients = [
            Ingredient(id: "0", name: "milk", quantity: "2", unit: "cup"),
            Ingredient(id: "1", name: "tea", quantity: "1/2", unit: "cup"),
            Ingredient(id: "2", name: "sugar", quantity: "2", unit: "tblsp")
        ]
        let steps = [
            "Mix sugar and tea",
            "Add milk"
        ]
        let boba_recipe = Recipe(id: UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e")!, image: "simple_milk_tea", name: "boba", author: "Micky Abir", rating: 4.5, ingredients: ingredients, steps: steps, emoji: "🧋", favorited: 100)
        let recipes = [boba_recipe]
        RecipesMainView(recipes: recipes)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
