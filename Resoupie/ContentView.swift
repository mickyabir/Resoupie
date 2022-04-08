//
//  ContentView.swift
//  Resoupie
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 1
    
    let backendController: BackendController
    @StateObject var profileOwnerViewController: ProfileOwnerViewController = ProfileOwnerViewController()
    let recipeMainViewController: RecipeMainViewController
    let favoritesViewController: FavoritesViewController
    let worldViewController: WorldViewController
    
    @State var presentNewRecipe: Bool = false
    
    init() {
        backendController = BackendController()
        recipeMainViewController = RecipeMainViewController(backendController)
        favoritesViewController = FavoritesViewController(backendController)
        worldViewController = WorldViewController(backendController)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
                        Label("Profile", systemImage: "person.crop.circle" + (profileOwnerViewController.notificationsAvailable ? ".badge" : ""))
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
            }
            
            if selection >= 1 && selection <= 3 && profileOwnerViewController.signedIn {
                Button {
                    presentNewRecipe = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .padding(8)
                }
                .font(.system(size: 36))
                .background(
                    Circle()
                        .foregroundColor(Color.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 10)
                )
                .padding(.trailing, 30)
                .padding(.bottom, 70)
            }
        }
        .sheet(isPresented: $presentNewRecipe) {
            NavigationView {
                EditRecipeView(isPresented: $presentNewRecipe)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                presentNewRecipe = false
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }
                
            }
        }

    }
}
