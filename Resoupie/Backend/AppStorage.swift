//
//  AppStorage.swift
//  Resoupie
//
//  Created by Michael Abir on 2/27/22.
//

import Foundation
import SwiftUI

class AppStorageContainer {
    static var main = AppStorageContainer()
    
    @AppStorage("username") var username: String = ""
    @AppStorage("user_id") var user_id: String = ""
    @AppStorage("groceryLists") var groceries: [GroceryList] = []
}

// MARK: Groceries
extension AppStorageContainer {
    private func hashRecipeToId(_ recipeMeta: RecipeMeta) -> String {
        return recipeMeta.id
    }
    
    private func hashIngredientToId(_ ingredient: Ingredient) -> String {
        return getIngredientString(ingredient)
    }
    
    private func getIngredientString(_ ingredient: Ingredient) -> String {
        return ingredient.name + " (" + ingredient.quantity + " " + ingredient.unit +  ")"
    }
    
    func recipeListExists(_ recipeMeta: RecipeMeta) -> Bool {
        return groceries.firstIndex(where: { $0.id == hashRecipeToId(recipeMeta) }) != nil
    }
    
    func removeRecipeList(_ recipeMeta: RecipeMeta) {
        if let listIndex = groceries.firstIndex(where: { $0.id == hashRecipeToId(recipeMeta) }) {
            groceries.remove(at: listIndex)
        }
    }
    
    func ingredientsInGroceryList(_ recipeMeta: RecipeMeta) -> [Bool] {
        if let listIndex = groceries.firstIndex(where: { $0.id == hashRecipeToId(recipeMeta) }) {
            return recipeMeta.recipe.ingredients.map { ingredient in
                groceries[listIndex].items.firstIndex(where: { $0.id == hashIngredientToId(ingredient) }) != nil
            }
        } else {
            return recipeMeta.recipe.ingredients.map { _ in false }
        }
    }
    
    func insertListFromRecipe(_ recipeMeta: RecipeMeta) {
        let groceryListItems = recipeMeta.recipe.ingredients.map({ GroceryListItem(id: hashIngredientToId($0), ingredient: getIngredientString($0), check: false) })

        if let listIndex = groceries.firstIndex(where: { $0.id == hashRecipeToId(recipeMeta) }) {
            groceries[listIndex].items.insert(contentsOf: groceryListItems, at: 0)
            groceries[listIndex].items = groceries[listIndex].items.uniqued().sorted(by: { $0.ingredient < $1.ingredient })
        } else {
            groceries.append(GroceryList(id: hashRecipeToId(recipeMeta), name: recipeMeta.recipe.name, items: groceryListItems))
        }
    }
    
    func insertIngredient(_ ingredient: Ingredient, recipeMeta: RecipeMeta) {
        if ingredientInList(ingredient, recipeMeta: recipeMeta) {
            return
        }
        
        var listIndex: Int
        let listId = hashRecipeToId(recipeMeta)
        
        if let foundIndex = groceries.firstIndex(where: { $0.id == listId }) {
            listIndex = foundIndex
        } else {
            groceries.append(GroceryList(id: listId, name: recipeMeta.recipe.name, items: []))
            listIndex = groceries.count - 1
        }
        
        groceries[listIndex].items.append(GroceryListItem(id: hashIngredientToId(ingredient), ingredient: getIngredientString(ingredient), check: false))
        groceries[listIndex].items = groceries[listIndex].items.sorted(by: { $0.ingredient < $1.ingredient })
    }
    
    func removeIngredient(_ ingredient: Ingredient, recipeMeta: RecipeMeta) {
        let listId = hashRecipeToId(recipeMeta)
        
        if let listIndex = groceries.firstIndex(where: { $0.id == listId }) {
            if let itemIndex = groceries[listIndex].items.firstIndex(where: { $0.id == hashIngredientToId(ingredient) }) {
                groceries[listIndex].items.remove(at: itemIndex)
            }
            
            if groceries[listIndex].items.isEmpty {
                groceries.remove(at: listIndex)
            }
        }
    }
    
    func ingredientInList(_ ingredient: Ingredient, recipeMeta: RecipeMeta) -> Bool {
        let listId = hashRecipeToId(recipeMeta)

        if let listIndex = groceries.firstIndex(where: { $0.id == listId }) {
            if let _ = groceries[listIndex].items.firstIndex(where: { $0.id == hashIngredientToId(ingredient) }) {
                return true
            }
        }
        
        return false
    }
    
//    func insertGroceryListItem(_ item: GroceryListItem, recipeMeta: RecipeMeta) {
//        var listIndex: Int
//        let listId = hashRecipeToId(recipeMeta)
//
//        if let foundIndex = groceries.firstIndex(where: { $0.id == listId }) {
//            listIndex = foundIndex
//        } else {
//            groceries.append(GroceryList(id: listId, name: recipeMeta.recipe.name, items: []))
//            listIndex = groceries.count - 1
//        }
//
//        groceries[listIndex].items.append(item)
//        groceries[listIndex].items = groceries[listIndex].items.sorted(by: { $0.ingredient < $1.ingredient })
//    }
    
    func deleteCheckedItems() {
        for index in 0..<groceries.count {
            groceries[index].items = groceries[index].items.filter({ !$0.check })
        }
    }
}
