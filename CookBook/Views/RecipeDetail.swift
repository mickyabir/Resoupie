//
//  RecipeDetail.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

struct RecipeDetail: View {
    @State private var favorited: Bool = false
    var recipe: Recipe
    @AppStorage("favorites") var favorites: [Recipe] = []
    @AppStorage("groceries") var groceries: [GroceryListItem] = []
    
    var body: some View {
        ZStack {
            Color.background
            
            ScrollView {
                VStack(alignment: .leading) {
                    CustomAsyncImage(imageId: recipe.image, width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.width - 20, cornerRadius: 10)
                        .padding(.leading, 10)
                    Text(String(recipe.rating))
                    
                    Spacer()
                    
                    ForEach (recipe.ingredients) { ingredient in
                        HStack {
                            AddFillButton() {
                                let index = groceries.firstIndex(where: {$0.id == (recipe.id.uuidString + "_" + ingredient.id)})
                                return index != nil
                            } action: { tapped in
                                let index = groceries.firstIndex(where: {$0.id == (recipe.id.uuidString + "_" + ingredient.id)})
                                if tapped {
                                    if index == nil {
                                        groceries.append(GroceryListItem(id: recipe.id.uuidString + "_" + ingredient.id, ingredient: ingredient, check: false))
                                    }
                                } else {
                                    if index != nil {
                                        groceries.remove(at: index!)
                                    }
                                }
                            }
                            
                            Text(ingredient.quantity)
                            Text(ingredient.unit)
                            Text("of")
                            Text(ingredient.name)
                        }
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading) {
                        ForEach (recipe.steps, id: \.self) { step in
                            HStack {
                                ZStack{
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color.orange)
                                    let index = recipe.steps.firstIndex(of: step)! + 1
                                    Text(String(index))
                                        .foregroundColor(Color.white)
                                }
                                
                                Text(step)
                                    .padding()
                            }
                        }
                    }
                }.frame(maxWidth: .infinity)
            }
            .onAppear {
                if favorites.firstIndex(where: {$0.id == recipe.id}) != nil {
                    favorited = true
                } else {
                    favorited = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(recipe.name).font(.headline)
                        Text(recipe.author).font(.subheadline)
                    }
                }
            }
            .navigationBarItems(trailing:
                                    Button(action: {
                favorited.toggle()
                
                if favorited {
                    favorites.append(recipe)
                } else {
                    if let offset = favorites.firstIndex(where: {$0.id == recipe.id}) {
                        favorites.remove(at: offset)
                    }
                    
                }
            }) {
                Image(systemName: favorited ? "heart.fill" : "heart")
                    .foregroundColor(Color.red)
            })
        }
        
    }
}

struct RecipeDetail_Previews: PreviewProvider {
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
        RecipeDetail(recipe: boba_recipe)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
