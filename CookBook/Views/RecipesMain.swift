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
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.lightGray)
                .shadow(color: Color.black.opacity(0.12), radius: 4)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .padding()
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.lightText)
                    .padding(.leading)
                
                TextField("", text: $searchText)
                    .foregroundColor(.lightText)
                    .padding(.trailing)
            }
            .padding(.horizontal)

        }
    }
}

struct RecipeGroupRow: View {
    var title: String
    var recipes: [RecipeMeta]
    @AppStorage("favorites") var favorites: [RecipeMeta] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title3)
                .padding(.leading)
                .foregroundColor(Color.title3)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(recipes) { recipe in
                        ZStack {
                            RecipeCard(recipeMeta: recipe, width: 250)

                            let favorited = (favorites.firstIndex(of: recipe) != nil)
                            Image(systemName: favorited ? "heart.fill" : "heart")
                                .foregroundColor(favorited ? Color.red : Color.white)
                                .font(.system(size: 18))
                                .offset(x: 100, y: -130)
                        }
                        .padding(.bottom, 5)
                    }
                }
                .padding(.leading)
            }
        }
    }
}

struct RecipesMainView: View {
    @State var recipes: [RecipeMeta] = [RecipeMeta]()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        SearchField()
                        
                        Group {
                            RecipeGroupRow(title: "Popular", recipes: recipes)
                            
                            Rectangle()
                                .foregroundColor(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 5)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                            
                            RecipeGroupRow(title: "For You", recipes: recipes)
                            
                            Rectangle()
                                .foregroundColor(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 5)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                            
                            RecipeGroupRow(title: "Vegan", recipes: recipes)
                        }
                        .onTapGesture {
                            let resign = #selector(UIResponder.resignFirstResponder)
                            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                        }
                    }
                    .navigationTitle("Recipes")
                }
                .simultaneousGesture(
                    DragGesture().onChanged { value in
                        let resign = #selector(UIResponder.resignFirstResponder)
                        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                    }
                )
            }
        }
        .onAppear {
            loadRecipes()
        }
    }
    
    func loadRecipes() {
        let recipeBackendController = RecipeBackendController()
        let _ = recipeBackendController.loadAllRecipes { allRecipes in
            self.recipes = allRecipes
        }
    }
}
