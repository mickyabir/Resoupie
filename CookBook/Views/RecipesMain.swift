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
                
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.lightText)
                        .padding(.trailing)
                        .opacity(searchText != "" ? 1.0 : 0.0)
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
                }
            }
        }
    }
}

struct RecipeMainDefaultView: View {
    @State var recipes: [RecipeMeta] = [RecipeMeta]()

    var body: some View {
        LazyVStack {
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
        }
        .onAppear() {
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

struct RecipeMainContinuousView: View {
    @State var recipes: [RecipeMeta] = [RecipeMeta]()

    var body: some View {
        LazyVStack {
            ForEach(recipes) { recipe in
                RecipeCard(recipeMeta: recipe, width: UIScreen.main.bounds.size.width - 40)
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
        let recipeBackendController = RecipeBackendController()
        let _ = recipeBackendController.loadNextRecipes(skip: 0, limit: 1) { allRecipes in
            self.recipes = allRecipes
        }
    }
    
    func loadMoreRecipes() {
        let recipeBackendController = RecipeBackendController()
        let _ = recipeBackendController.loadNextRecipes(skip: recipes.count, limit: 1) { allRecipes in
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
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                Color.background
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        Group {
                            if continuous {
                                RecipeMainContinuousView()
                            } else {
                                RecipeMainDefaultView()
                            }
                        }
                        .padding(.top)
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
                .navigationTitle("CookBooks")
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
