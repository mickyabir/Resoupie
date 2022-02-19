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
        
    let backendController = RecipeBackendController()
    
    @State var currentServings: Int?
    
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
                            .onTapGesture {
                                let rating = index + 1
                                backendController.rateRecipe(recipe_id: recipeMeta.id, rating: rating)
                            }
                    }
                    
                    if halfStar {
                        Image(systemName: "star.leadinghalf.filled")
                            .foregroundColor(Color.yellow)
                            .onTapGesture {
                                let rating = stars + 1
                                backendController.rateRecipe(recipe_id: recipeMeta.id, rating: rating)
                            }
                    }
                    
                    ForEach(0..<emptyStars) { index in
                        Image(systemName: "star")
                            .foregroundColor(Color.yellow)
                            .onTapGesture {
                                let rating = stars + (halfStar ? 1 : 0) + index + 1
                                backendController.rateRecipe(recipe_id: recipeMeta.id, rating: rating)
                            }
                    }
                    
                    Text(String(rating))
                        .foregroundColor(Color.lightText)
                    
                    Spacer()
                }
                
                if !recipeMeta.recipe.specialTools.isEmpty {
                    Section(header: HStack {
                        Text("Special Tools").foregroundColor(Color.title).font(.title2).fontWeight(.semibold)
                    }) {
                        ForEach(recipeMeta.recipe.specialTools.indices, id: \.self) { index in
                            Text(recipeMeta.recipe.specialTools[index])
                                .foregroundColor(Color.text)
                        }
                    }
                    .textCase(nil)
                }
                
                Section(header:
                            HStack {
                    Text("Ingredients")
                        .foregroundColor(Color.title)
                    Spacer()
                    
                    VStack {
                        Text("Servings")
                            .foregroundColor(Color.lightText)
                            .font(.system(size: 14))
                        HStack {
                            Image(systemName: "minus")
                                .foregroundColor((currentServings ?? recipeMeta.recipe.servings) > 1 ? Color.orange : Color.lightText)
                                .onTapGesture {
                                    if currentServings == nil {
                                        currentServings = recipeMeta.recipe.servings
                                    }
                                    
                                    if currentServings! > 1 {
                                        currentServings! -= 1
                                    }
                                    
                                }
                            
                            Text(String(currentServings ?? recipeMeta.recipe.servings))
                                .foregroundColor(Color.lightText)
                            
                            Image(systemName: "plus")
                                .foregroundColor(Color.orange)
                                .onTapGesture {
                                    if currentServings == nil {
                                        currentServings = recipeMeta.recipe.servings
                                    }
                                    
                                    currentServings! += 1
                                }
                        }
                    }
                    
                    Spacer()
                    Image(systemName: groceriesAdded ? "folder.fill.badge.plus" : "folder.badge.plus")
                        .padding(.trailing, 20)
                        .foregroundColor(Color.orange)
                        .onTapGesture {
                            withAnimation {
                                groceriesAdded.toggle()
                            }
                            
                            if groceriesAdded {
                                groceries.append(GroceryList(id: recipeMeta.id, name: recipeMeta.recipe.name, items: []))
                                groceries[groceries.count - 1].items = recipeMeta.recipe.ingredients.map { GroceryListItem(id: recipeMeta.id + "_" + $0.id, ingredient: $0.name + " (" + $0.quantity + " " + $0.unit +  ")", check: false)}
                            } else {
                                groceries.removeAll(where: { $0.id == recipeMeta.id })
                            }
                            
                        }
                }) {
                    ForEach (recipeMeta.recipe.ingredients) { ingredient in
                        HStack {
                            let index = groceries.reduce([], { $0 + $1.items }).firstIndex(where: { $0.id == (recipeMeta.id + "_" + ingredient.id) })
                            
                            Image(systemName: index != nil ? "plus.circle.fill" : "plus.circle")
                                .onTapGesture {
                                    if index == nil {
                                        var currentQuantity = Double(ingredient.quantity) ?? 0
                                        if let currentServings = currentServings {
                                            currentQuantity = currentQuantity / Double(recipeMeta.recipe.servings) * Double(currentServings)
                                        }
                                        let ingredientString = ingredient.name + " (" + (currentQuantity > 0 ? String(currentQuantity) : ingredient.quantity) + " " + ingredient.unit +  ")"
                                        groceries[0].items.append(GroceryListItem(id: recipeMeta.id + "_" + ingredient.id, ingredient: ingredientString, check: false))
                                    } else if index != nil {
                                        for listIndex in 0..<groceries.count {
                                            if let itemIndex = groceries[listIndex].items.firstIndex(where: { $0.id == recipeMeta.id + "_" + ingredient.id }) {
                                                groceries[listIndex].items.remove(at: itemIndex)
                                            }
                                        }
                                    }
                                }
                                .foregroundColor(Color.orange)
                                .font(.system(size: 18))
                            
                            var currentQuantity = Double(ingredient.quantity) ?? 0
                            if let currentServings = currentServings {
                                let _ = (currentQuantity = currentQuantity / Double(recipeMeta.recipe.servings) * Double(currentServings))
                            }
                            let ingredientText = (currentQuantity > 0 ? String(currentQuantity) : ingredient.quantity) + " " + ingredient.unit + " " + ingredient.name
                            Text(ingredientText)
                                .foregroundColor(Color.text)
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                Section(header: Text("Method").foregroundColor(Color.title)) {
                    ForEach (recipeMeta.recipe.steps, id: \.self) { step in
                        let index = recipeMeta.recipe.steps.firstIndex(of: step)!
                        HStack {
                            Image(systemName: String(index + 1) + ".circle.fill")
                                .foregroundColor(Color.orange)
                                .font(.system(size: 24))
                            
                            Text(step)
                                .foregroundColor(Color.text)
                                .padding(.vertical, 5)
                        }
                    }
                }
                
                if !recipeMeta.recipe.tags.isEmpty {
                    Section(header: Text("Tags").foregroundColor(Color.title).font(.title2).fontWeight(.semibold)) {
                        FlexibleView(
                            data: recipeMeta.recipe.tags,
                            spacing: 15,
                            alignment: .leading
                        ) { item in
                            HStack {
                                Text(verbatim: item)
                                    .foregroundColor(Color.text)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }
                        .frame(minHeight: 20)
                    }
                    .textCase(nil)
                }
            }
            .onAppear {
                if favorites.firstIndex(where: {$0.id == recipeMeta.id}) != nil {
                    favorited = true
                } else {
                    favorited = false
                }
                
                groceriesAdded = groceries.firstIndex(where: { $0.id == recipeMeta.id }) != nil
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
                    backendController.favoriteRecipe(recipe_id: recipeMeta.id)
                } else {
                    if let offset = favorites.firstIndex(where: {$0.id == recipeMeta.id}) {
                        favorites.remove(at: offset)
                    }
                    backendController.unfavoriteRecipe(recipe_id: recipeMeta.id)
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
