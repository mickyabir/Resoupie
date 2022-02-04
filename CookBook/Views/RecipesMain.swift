//
//  RecipesMain.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

struct SearchField: View {
    @State var searchText = ""
    var action: (String) -> Void
    
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
                    .onSubmit {
                        action(searchText)
                    }
            }
            .padding(.horizontal)

        }
    }
}

struct RecipeGroupRow: View {
    var title: String
    var recipes: [RecipeMeta]
    @AppStorage("favorites") var favorites: [RecipeMeta] = []
    @State var scrollOffset: CGFloat = 0.0
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.leading)
                .foregroundColor(Color.title2)
            
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack {
                    LazyHStack {
                        ForEach(recipes) { recipe in
                            ZStack(alignment: .topTrailing) {
                                RecipeCard(recipeMeta: recipe, width: 250)
                                
                                let favorited = (favorites.firstIndex(of: recipe) != nil)
                                Image(systemName: favorited ? "heart.fill" : "heart")
                                    .foregroundColor(favorited ? Color.red : Color.white)
                                    .font(.system(size: 18))
                                    .padding(.top, 10)
                                    .padding(.trailing, 10)
                            }
                            .padding([.top, .bottom], 10)
                        }
                    }
                    .padding(.leading, 20)
                    
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .named("scroll")).minX
                        let _ = DispatchQueue.main.async {
                            self.scrollOffset = offset
                            print(self.scrollOffset)
                        }
                        Color.clear
                            .frame(width: 0, height: 0)
                    }
                }
            }
        }
    }
}

struct RecipesMainView: View {
    @State var recipes: [RecipeMeta] = [RecipeMeta]()
    @State var temp: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                ScrollView(showsIndicators: false) {
                    LazyVStack {
                        SearchField() { searchText in
                            print(searchText)
                        }
                        
                        Group {
                            RecipeGroupRow(title: "Popular", recipes: recipes)
                            
                            Rectangle()
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity, maxHeight: 6)
                            
                            RecipeGroupRow(title: "For You", recipes: recipes)
                            
                            Rectangle()
                                .foregroundColor(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 4)
                                .frame(maxWidth: .infinity, maxHeight: 6)
                                .padding(.vertical, 4)
                            
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
//            .navigationBarHidden(true)
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
