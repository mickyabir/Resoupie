//
//  RecipeDetail.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

struct AddFillButton: View {
    @State private var didTap: Bool = false
    
    var body: some View {
        Button {
            self.didTap = !self.didTap
        } label: {
            Image(systemName: didTap ? "plus.circle.fill" : "plus.circle")
                .frame(width: 18, height: 18)
                .clipShape(Circle())
        }
    }
}

struct RecipeDetail: View {
    @State private var favorited: Bool = false
    var recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack {
                Image("example_recipe_image")
                    .resizable()
                    .scaledToFit()
                Text(recipe.author)
                Text(String(recipe.rating))
                
                Spacer()
                
                ForEach (recipe.ingredients) { ingredient in
                    HStack {
                        AddFillButton()
                        
                        Text(ingredient.quantity)
                        Text(ingredient.unit)
                        Text("of")
                        Text(ingredient.name)
                    }
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                
                ForEach (recipe.steps, id: \.self) { step in
                    Text(step)
                }
            }.frame(maxWidth: .infinity)
        }
        .navigationBarTitle(recipe.name)
        .navigationBarItems(trailing:
                                Button(action: {
            favorited = !favorited
            
            var favorites: [Recipe] = []
            
            if let data = UserDefaults.standard.data(forKey: "favorites") {
                if let decoded = try? JSONDecoder().decode([Recipe].self, from: data) {
                    favorites = decoded
                }
            }
            
            if favorited {
                favorites.append(recipe)
            } else {
                if let offset = favorites.firstIndex(where: {$0.id == recipe.id}) {
                    favorites.remove(at: offset)
                }

            }
            
            if let encoded = try? JSONEncoder().encode(favorites) {
                UserDefaults.standard.set(encoded, forKey: "favorites")
            }
            
        }) {
            Image(systemName: favorited ? "heart.fill" : "heart")
        })
        
    }
}

struct RecipeDetail_Previews: PreviewProvider {
    static var previews: some View {
        let ingredients = [
            Ingredient(id: 0, name: "milk", quantity: "2", unit: "cup"),
            Ingredient(id: 1, name: "tea", quantity: "1/2", unit: "cup"),
            Ingredient(id: 2, name: "sugar", quantity: "2", unit: "tblsp")
        ]
        let steps = [
            "Mix sugar and tea",
            "Add milk"
        ]
        let boba_recipe = Recipe(id: UUID(), name: "boba", author: "Micky Abir", rating: 4.5, ingredients: ingredients, steps: steps)
        RecipeDetail(recipe: boba_recipe)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
