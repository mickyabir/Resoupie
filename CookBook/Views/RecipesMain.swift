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
            CustomAsyncImage(imageId: recipe.image, width: 512, height: 512, cornerRadius: 20)
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

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    static let lightGray = Color(red: 250 / 255, green: 250 / 255, blue: 250 / 255)
}

struct RecipesMainView: View {
    @State var recipes: [Recipe] = [Recipe]()

    var body: some View {
        NavigationView {
            ZStack {
                Color.lightGray
                VStack {
                    SearchField()
                    
                    VStack(alignment: .leading) {
                        Text("Popular")
                            .font(.headline)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(recipes) { recipe in
                                    PopularRecipeCard(recipe: recipe)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("Recipes")
            }
            .edgesIgnoringSafeArea(.all)
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

struct PopularRecipeCard: View {
    var recipe: Recipe
    @State var presentRecipe = false
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.white)
                .frame(width: 250, height: 250)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 5, y: 5)
            VStack {
                AsyncImage(url: URL(string: BackendController.url + "images/" + recipe.image)) { image in
                    image
                        .resizable()
                        .frame(width: 250, height: 200)
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(10)
                        .clipped()
                } placeholder: {
                    Color.orange
                }
                
                VStack {
                    Text(recipe.name)
                        .font(.headline)
                    Text(recipe.author)
                        .font(.subheadline)
                }
            }
        }
        .onTapGesture {
            presentRecipe = true
        }
        .padding(.horizontal, 5)
        .sheet(isPresented: $presentRecipe, content: {
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
