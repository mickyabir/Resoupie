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
    @AppStorage("groceryLists") var groceries: [GroceryList] = []

    @State var groceriesAdded = false
    
    @State var showLargeImage = false
    
    @State var stepsCompleted: [Bool] = []
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.background
            
            List {
                CustomAsyncImage(imageId: recipeMeta.recipe.image, width: UIScreen.main.bounds.size.width - 70, height: UIScreen.main.bounds.size.width - 70)
                    .cornerRadius(10)
                    .onTapGesture {
                        withAnimation {
                            showLargeImage = true
                        }
                    }
                
                HStack {
                    Spacer()
                    
                    let rating = recipeMeta.rating
                    let stars = Int(floor(rating))
                    let halfStar = rating.truncatingRemainder(dividingBy: 1) > 0.3
                    let emptyStars = 5 - stars - (halfStar ? 1 : 0)

                    ForEach(0..<stars) { index in
                        Image(systemName: "star.fill")
                            .foregroundColor(Color.yellow)
                    }
                    
                    if halfStar {
                        Image(systemName: "star.leadinghalf.filled")
                            .foregroundColor(Color.yellow)
                    }
                    
                    ForEach(0..<emptyStars) { index in
                        Image(systemName: "star")
                            .foregroundColor(Color.yellow)
                    }
                    
                    Text(String(rating))
                        .foregroundColor(Color.lightText)
                    
                    Spacer()
                }
                
                Section(header:
                            HStack {
                    Text("Ingredients")
                        .foregroundColor(Color.title)
                    Spacer()
                    Image(systemName: groceriesAdded ? "folder.fill.badge.plus" : "folder.badge.plus")
                        .padding(.trailing, 20)
                        .foregroundColor(Color.orange)
                        .onTapGesture {
                            withAnimation {
                                groceriesAdded.toggle()
                            }
                            
                            if groceriesAdded {
                                groceries.append(GroceryList(id: recipeMeta.id.uuidString, name: recipeMeta.recipe.name, items: []))
                                groceries[groceries.count - 1].items = recipeMeta.recipe.ingredients.map { GroceryListItem(id: recipeMeta.id.uuidString + "_" + $0.id, ingredient: $0.name + " (" + $0.quantity + " " + $0.unit +  ")", check: false)}
                            } else {
                                groceries.removeAll(where: { $0.id == recipeMeta.id.uuidString })
                            }
                            
                        }
                }) {
                    ForEach (recipeMeta.recipe.ingredients) { ingredient in
                        HStack {
                            let index = groceries.reduce([], { $0 + $1.items }).firstIndex(where: { $0.id == (recipeMeta.id.uuidString + "_" + ingredient.id) })
                            
                            Image(systemName: index != nil ? "plus.circle.fill" : "plus.circle")
                                .onTapGesture {
                                    if index == nil {
                                        let ingredientString = ingredient.name + " (" + ingredient.quantity + " " + ingredient.unit +  ")"
                                        groceries[0].items.append(GroceryListItem(id: recipeMeta.id.uuidString + "_" + ingredient.id, ingredient: ingredientString, check: false))
                                    } else if index != nil {
                                        for listIndex in 0..<groceries.count {
                                            if let itemIndex = groceries[listIndex].items.firstIndex(where: { $0.id == recipeMeta.id.uuidString + "_" + ingredient.id }) {
                                                groceries[listIndex].items.remove(at: itemIndex)
                                            }
                                        }
                                    }
                                }
                                .foregroundColor(Color.orange)
                                .font(.system(size: 18))
                            
                            let ingredientText = ingredient.quantity + " " + ingredient.unit + " " + ingredient.name
                            Text(ingredientText)
                                .foregroundColor(Color.text)
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                Section(header: Text("Method").foregroundColor(Color.title)) {
                    VStack(alignment: .leading) {
                        ForEach (recipeMeta.recipe.steps, id: \.self) { step in
                            let index = recipeMeta.recipe.steps.firstIndex(of: step)!
                            let completed = stepsCompleted[index]
                            HStack {
                                Image(systemName: String(index + 1) + (completed ? ".circle.fill" : ".circle"))
                                    .foregroundColor(Color.orange)
                                    .font(.system(size: 24))
                                
                                Text(step)
                                    .strikethrough(completed, color: Color.lightText)
                                    .foregroundColor(completed ? Color.lightText : Color.text)
                                    .padding(.vertical, 5)
                            }
                            .onTapGesture {
                                stepsCompleted[index].toggle()
                            }
                        }
                    }
                }
            }
            .onAppear {
                if favorites.firstIndex(where: {$0.id == recipeMeta.id}) != nil {
                    favorited = true
                } else {
                    favorited = false
                }
                
                groceriesAdded = groceries.firstIndex(where: { $0.id == recipeMeta.id.uuidString }) != nil
                
                stepsCompleted = [Bool](repeating: false, count: recipeMeta.recipe.steps.count)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(recipeMeta.recipe.name).font(.headline).foregroundColor(Color.navbarTitle)
                        Text(recipeMeta.recipe.author).font(.subheadline).foregroundColor(Color.lightText)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
            
            Color.black.opacity(showLargeImage ? 0.7 : 0.0)
            
            CustomAsyncImage(imageId: recipeMeta.recipe.image, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
                .onTapGesture {
                    withAnimation {
                        showLargeImage = false
                    }
                }
                .opacity(showLargeImage ? 1.0 : 0.0)
                .offset(y: 60)

        }
        .accentColor(Color.orange)
    }
}
