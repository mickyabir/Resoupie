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

    let test: BackendController & RecipeBackendController = BackendController()
    
    let backendController = BackendController()

    var body: some View {
        TabView(selection: $selection) {
            WorldView()
                .tabItem {
                    Label("World", systemImage: "globe")
                }
                .tag(0)
            
            RecipesMainView(backendController: backendController)
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife")
                }
                .tag(1)
            
            ProfileView(viewController: ProfileViewController(backendController: backendController))
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
        .accentColor(Color.orange)
        .onChange(of: selection) { selected in
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
