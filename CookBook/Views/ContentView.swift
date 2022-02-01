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
    var recipes: [Recipe]
    @AppStorage("favorites") var favorites: [Recipe] = []
    @State private var selection = 1
    @State private var oldSelection = 1
    @StateObject var presentNewRecipe = PresentNewRecipe()


    var body: some View {
        TabView(selection: $selection) {
            WorldView()
                .tabItem {
                    Label("World", systemImage: "globe")
                }
                .tag(0)
            
            RecipesMainView(recipes: recipes)
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife")
                }
                .tag(1)
            
            Text("")
                .tabItem {
                    Label("New", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            FavoritesView(favorites: favorites)
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
        .accentColor(Color.orange)
        .onChange(of: selection) { selected in
            if selected == 2 {
                presentNewRecipe.showNewRecipe = true
            } else {
                self.oldSelection = selected
            }
        }
        .sheet(isPresented: $presentNewRecipe.showNewRecipe, onDismiss: {
            self.selection = self.oldSelection
        }) {
            NavigationView {
                NewRecipeView()
            }
        }
        .environmentObject(presentNewRecipe)
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
        ContentView(recipes: recipes, favorites: recipes)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
