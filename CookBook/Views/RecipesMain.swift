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
            CustomAsyncImage(imageId: recipe.image)
            VStack {
                Text(recipe.name)
                    .fontWeight(.medium)
                Text(recipe.author)
                    .fontWeight(.light)
                    .foregroundColor(Color.gray)
            }
            .offset(x: 40)
        }
    }
}

struct SearchField: View {
    @State private var searchText = ""

    var body: some View {
        HStack(spacing: 4) {
            CustomTextField("", text: $searchText)
            Button {
                
            } label: {
                Image(systemName: "magnifyingglass")
            }
        }
        .padding(.horizontal)
    }
}

struct RecipesMainView: View {
    @State var recipes: [Recipe] = [Recipe]()

    var body: some View {
        NavigationView {
            VStack {
                SearchField()
                
                List(recipes) { recipe in
                    NavigationLink {
                        RecipeDetail(recipe: recipe)
                    } label: {
                        RecipeRow(recipe: recipe)
                    }
                }
                .refreshable {
                    loadRecipes()
                }
            }
            .navigationTitle("Recipes")
        }
        .onAppear {
            loadRecipes()
        }
    }
    
    func loadRecipes() {
        let recipeBackendController = RecipeBackendController()
        let _ = recipeBackendController.loadAllRecipes { allRecipes in
            self.recipes = allRecipes
            print("Recipes: ")
            print(self.recipes)
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
        let boba_recipe = Recipe(id: UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e")!, image: "simple_milk_tea", name: "boba", author: "Micky Abir", rating: 4.5, ingredients: ingredients, steps: steps, emoji: "🧋", favorited: 100, servings: 1)
        let recipes = [boba_recipe]
        RecipesMainView(recipes: recipes)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
