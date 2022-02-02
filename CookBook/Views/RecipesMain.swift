//
//  RecipesMain.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

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

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    static let lightGray = Color(red: 250 / 255, green: 250 / 255, blue: 250 / 255)
    static let backgroundPeach = Color(red: 255 / 255, green: 247 / 255, blue: 242 / 255)
}

struct RecipesMainView: View {
    @State var recipes: [Recipe] = [Recipe]()
    @AppStorage("favorites") var favorites: [Recipe] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPeach
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        SearchField()
                        
                        VStack(alignment: .leading) {
                            Text("Popular")
                                .font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(recipes) { recipe in
                                        ZStack {
                                            PopularRecipeCard(recipe: recipe, width: 250)

                                            let favorited = (favorites.firstIndex(of: recipe) != nil)
                                            Image(systemName: favorited ? "heart.fill" : "heart")
                                                .foregroundColor(favorited ? Color.red : Color.white)
                                                .font(.system(size: 18))
                                                .offset(x: 100, y: -130)
                                        }
                                    }
                                }
                                .padding()
                                .padding(.vertical, 20)
                            }
                        }
                    }
                    .navigationTitle("Recipes")
                }
            }
        }
        .onAppear {
            loadRecipes()
        }
        .onTapGesture {
            let resign = #selector(UIResponder.resignFirstResponder)
            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
        }
    }
    
    func loadRecipes() {
        let recipeBackendController = RecipeBackendController()
        let _ = recipeBackendController.loadAllRecipes { allRecipes in
            self.recipes = allRecipes
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

struct PopularRecipeCard: View {
    var recipe: Recipe
    var width: CGFloat

    @State var presentRecipe = false
    @State var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.lightGray)
                .shadow(color: Color.black.opacity(0.15), radius: 10)
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: BackendController.url + "images/" + recipe.image)) { image in
                    image
                        .resizable()
                        .frame(width: width, height: width)
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(10)
                        .clipped()
                } placeholder: {
                    Color.orange
                }
                
                VStack(spacing: 2) {
                    Group {
                        Text(recipe.name)
                            .font(.headline)
                        Text(recipe.author)
                            .font(.subheadline)
                        HStack {
                            let starsBound = Int(floor(recipe.rating) - 1) > 0 ? Int(floor(recipe.rating) - 1) : 0
                            HStack(spacing: 2) {
                                ForEach(0..<starsBound) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.subheadline)
                                        .foregroundColor(Color.yellow)
                                        .font(.system(size: 14))
                                }
                                ForEach(starsBound..<5) { _ in
                                    Image(systemName: "star")
                                        .font(.subheadline)
                                        .foregroundColor(Color.yellow)
                                        .font(.system(size: 14))
                                }
                            }
                            Text("(" + String(recipe.rating) + ")")
                                .opacity(0.5)
                                .font(.system(size: 14))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(width: width, height: width + 50)
        .onTapGesture {
            presentRecipe = true
        }
        .padding(.horizontal, 5)
        .popover(isPresented: $presentRecipe, content: {
            NavigationView {
                RecipeDetail(recipe: recipe)
                    .navigationBarItems(leading:
                                            Button(action: {
                        presentRecipe = false
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color.orange)
                    })
            }
        })
    }
}
