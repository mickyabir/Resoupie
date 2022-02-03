//
//  RecipeDetail.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

struct RecipeDetail: View {
    @State private var favorited: Bool = false
    var recipeMeta: RecipeMeta
    @AppStorage("favorites") var favorites: [RecipeMeta] = []
    @AppStorage("groceries") var groceries: [GroceryListItem] = []
    
    var body: some View {
        ZStack {
            Color.background
            
            ScrollView {
                VStack(alignment: .leading) {
                    CustomAsyncImage(imageId: recipeMeta.recipe.image, width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.width - 20, cornerRadius: 10)
                        .padding(.leading, 10)
                    Text(String(recipeMeta.rating))
                    
                    Spacer()
                    
                    ForEach (recipeMeta.recipe.ingredients) { ingredient in
                        HStack {
                            AddFillButton() {
                                let index = groceries.firstIndex(where: {$0.id == (recipeMeta.id.uuidString + "_" + ingredient.id)})
                                return index != nil
                            } action: { tapped in
                                let index = groceries.firstIndex(where: {$0.id == (recipeMeta.id.uuidString + "_" + ingredient.id)})
                                if tapped {
                                    if index == nil {
                                        groceries.append(GroceryListItem(id: recipeMeta.id.uuidString + "_" + ingredient.id, ingredient: ingredient, check: false))
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
                        ForEach (recipeMeta.recipe.steps, id: \.self) { step in
                            HStack {
                                ZStack{
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color.orange)
                                    let index = recipeMeta.recipe.steps.firstIndex(of: step)! + 1
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
                if favorites.firstIndex(where: {$0.id == recipeMeta.id}) != nil {
                    favorited = true
                } else {
                    favorited = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(recipeMeta.recipe.name).font(.headline)
                        Text(recipeMeta.recipe.author).font(.subheadline)
                    }
                }
            }
            .navigationBarItems(trailing:
                                    Button(action: {
                favorited.toggle()
                
                if favorited {
                    favorites.append(recipeMeta)
                } else {
                    if let offset = favorites.firstIndex(where: {$0.id == recipeMeta.id}) {
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
