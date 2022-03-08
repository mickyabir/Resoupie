//
//  ContentView.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 1
    
    let backendController: BackendController
    let profileOwnerViewController: ProfileOwnerViewController
    let recipeMainViewController: RecipeMainViewController
    let favoritesViewController: FavoritesViewController
    let worldViewController: WorldViewController
    
    init() {
        backendController = BackendController()
        profileOwnerViewController = ProfileOwnerViewController(backendController)
        recipeMainViewController = RecipeMainViewController(backendController)
        favoritesViewController = FavoritesViewController(backendController)
        worldViewController = WorldViewController(backendController)
    }
    
    var body: some View {
        TabView(selection: $selection) {
            WorldView(viewController: worldViewController)
                .tabItem {
                    Label("World", systemImage: "globe")
                }
                .tag(0)

            RecipesMainView(viewController: recipeMainViewController)
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife")
                }
                .tag(1)

            ProfileOwnerView(viewController: profileOwnerViewController)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(2)

            FavoritesView(viewController: favoritesViewController)
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
                .tag(3)
            
            GroceriesView()
                .tabItem {
                    Label("Groceries", systemImage: "checklist")
                }
                .tag(4)
            
//            let ingredients: [Ingredient] = [
//
//            ]
//            let recipe = Recipe(image: "621c33b12cfadc340f1c20bd", name: "Spaghetti", ingredients: ingredients, steps: ["Step 1", "Step 2"], coordinate_lat: nil, coordinate_long: nil, emoji: "🍝", servings: 2, tags: ["vegan", "italian"], time: "25 min", specialTools: ["Tool 1"], parent_id: nil)
//            let recipeMeta = RecipeMeta(id: "", author: "Micky Abir", user_id: "", recipe: recipe, rating: 4.3, favorited: 82)
//            NewRecipeDetail(viewController: RecipeDetailViewController(recipeMeta: recipeMeta, backendController: BackendController()))
//                .tabItem {
//                    Label("Test", systemImage: "testtube.2")
//                        .tag(1)
//                }
            
        }
    }
}
