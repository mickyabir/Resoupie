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
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 5)
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
//        HStack(spacing: 4) {
//            TextField("", text: $searchText)
//            Button {
//
//            } label: {
//                Image(systemName: "magnifyingglass")
//            }
//        }
//        .padding(.horizontal)
    }
}

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    static let lightGray = Color(red: 250 / 255, green: 250 / 255, blue: 250 / 255)
    static let backgroundPeach = Color(red: 255 / 255, green: 247 / 255, blue: 242 / 255)
    static let navbarPeach = Color(red: 255 / 255, green: 253 / 255, blue: 251 / 255)
    static let lightText = Color(red: 153 / 255, green: 136 / 255, blue: 124 / 255)
    static let text = Color(red: 105 / 255, green: 84 / 255, blue: 70 / 255)
}

struct RecipeGroupRow: View {
    var title: String
    var recipes: [Recipe]
    @AppStorage("favorites") var favorites: [Recipe] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title3)
                .padding(.leading)
                .foregroundColor(Color.text)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(recipes) { recipe in
                        ZStack {
                            RecipeCard(recipe: recipe, width: 250)

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
}

struct RecipesMainView: View {
    @State var recipes: [Recipe] = [Recipe]()
    
    init (recipes: [Recipe]) {
        self.recipes = recipes
        Theme.navigationBarColors(background: UIColor(Color.navbarPeach), titleColor: UIColor(Color.text))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPeach
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

class Theme {
    static func navigationBarColors(background : UIColor?,
       titleColor : UIColor? = nil, tintColor : UIColor? = nil ){
        
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = background ?? .clear
        
        navigationAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .black]
        navigationAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .black]
       
        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance

        UINavigationBar.appearance().tintColor = tintColor ?? titleColor ?? .black
    }
}
