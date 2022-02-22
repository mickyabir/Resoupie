//
//  ContentView.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

class PresentNewRecipe: ObservableObject {
    @Published var showNewRecipe = false
}

struct ContentView: View {
    @AppStorage("favorites") var favorites: [RecipeMeta] = []
    @State private var selection = 1
    
    let backendController: BackendController
    let profileViewController: ProfileViewController
    let recipeMainViewController: RecipeMainViewController
    let newRecipeViewController: NewRecipeViewController

    init() {
        backendController = BackendController()
        profileViewController = ProfileViewController(backendController: backendController)
        recipeMainViewController = RecipeMainViewController(backendController: backendController)
        newRecipeViewController = NewRecipeViewController(backendController)
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                WorldView()
                    .tabItem {
                        Label("World", systemImage: "globe")
                    }
                    .tag(0)
                
                RecipesMainView(viewController: recipeMainViewController)
                    .tabItem {
                        Label("Recipes", systemImage: "fork.knife")
                    }
                    .tag(1)
                
                ProfileView(viewController: profileViewController, newRecipeViewController: newRecipeViewController)
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(2)
                
                FavoritesView(favorites: favorites, backendController: backendController)
                    .tabItem {
                        Label("Favorites", systemImage: "heart")
                    }
                    .tag(3)
                
                GroceriesView()
                    .tabItem {
                        Label("Groceries", systemImage: "checklist")
                    }
                    .tag(4)
            }
        }
        .accentColor(Color.orange)
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
