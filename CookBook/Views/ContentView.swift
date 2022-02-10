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
    @State private var oldSelection = 1
    @StateObject var presentNewRecipe = PresentNewRecipe()


    var body: some View {
        TabView(selection: $selection) {
            WorldView()
                .tabItem {
                    Label("World", systemImage: "globe")
                }
                .tag(0)
            
            RecipesMainView()
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
