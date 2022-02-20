//
//  RecipesMain.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

struct RecipeGroupRow: View {
    var title: String
    var recipes: [RecipeMeta]
    @AppStorage("favorites") var favorites: [RecipeMeta] = []
    
    let backendController: RecipeBackendController
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundColor(Color.background)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.leading)
                .padding(.top, 10)
                .foregroundColor(Color.title2)
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack {
                    LazyHStack {
                        ForEach(recipes) { recipe in
                            ZStack(alignment: .topTrailing) {
                                RecipeCard(RecipeCardViewController(recipeMeta: recipe, width: 250, backendController: backendController))
                                
                                let favorited = (favorites.firstIndex(of: recipe) != nil)
                                Image(systemName: favorited ? "heart.fill" : "heart")
                                    .foregroundColor(favorited ? Color.red : Color.white)
                                    .font(.system(size: 18))
                                    .padding(.top, 10)
                                    .padding(.trailing, 10)
                            }
                            .padding(.top, 50)
                        }
                    }
                    .padding(.leading, 20)
                }
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 500)
    }
}

struct RecipeMainDefaultView: View {
    @State var recipes: [RecipeMeta] = [RecipeMeta]()
    let backendController: RecipeBackendController

    var body: some View {
        LazyVStack {
            RecipeGroupRow(title: "Popular", recipes: recipes, backendController: backendController)
            
            RecipeGroupRow(title: "For You", recipes: recipes, backendController: backendController)
            
            RecipeGroupRow(title: "Vegan", recipes: recipes, backendController: backendController)
        }
        .onAppear() {
            loadRecipes()
        }
    }
    
    func loadRecipes() {
        let _ = backendController.loadAllRecipes { allRecipes in
            self.recipes = allRecipes
        }
    }
}

struct RecipeMainContinuousView: View {
    @State var recipes: [RecipeMeta] = [RecipeMeta]()
    let backendController: RecipeBackendController

    var body: some View {
        LazyVStack {
            ForEach(recipes) { recipe in
                RecipeCard(RecipeCardViewController(recipeMeta: recipe, width: UIScreen.main.bounds.size.width - 40, backendController: backendController))
                let thresholdIndex = recipes.index(recipes.endIndex, offsetBy: -1)
                if recipes.firstIndex(where: { $0.id == recipe.id }) == thresholdIndex {
                    let _ = loadMoreRecipes()
                }
            }
        }
        .onAppear() {
            loadRecipes()
        }
    }
    
    func loadRecipes() {
        let _ = backendController.loadNextRecipes(skip: 0, limit: 1) { allRecipes in
            self.recipes = allRecipes
        }
    }
    
    func loadMoreRecipes() {
        let _ = backendController.loadNextRecipes(skip: recipes.count, limit: 1) { allRecipes in
            print("load more")
            print(allRecipes)
            self.recipes.append(contentsOf: allRecipes)
        }
    }
}

struct RecipesMainView: View {
    @State var temp: String = ""
    @State var continuous: Bool = false
    @State var searchText: String = ""
    
    let backendController: RecipeBackendController
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                Color.white
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        Group {
                            if continuous {
                                RecipeMainContinuousView(backendController: backendController)
                            } else {
                                RecipeMainDefaultView(backendController: backendController)
                            }
                        }
                        .onTapGesture {
                            let resign = #selector(UIResponder.resignFirstResponder)
                            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                        }

                    }
                }
                .simultaneousGesture(
                    DragGesture().onChanged { value in
                        let resign = #selector(UIResponder.resignFirstResponder)
                        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                    }
                )
                .navigationTitle("Recipes")
                .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            continuous.toggle()
                        }
                    } label: {
                        Image(systemName: continuous ? "infinity.circle.fill" : "infinity.circle")
                            .font(.system(size: 22))
                            .foregroundColor(Color.orange)
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always)) {
                Text("Example search").searchCompletion("Example search")
            }
        }
    }
}
