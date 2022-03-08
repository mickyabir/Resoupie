//
//  AppStorage.swift
//  CookBook
//
//  Created by Michael Abir on 2/27/22.
//

import Foundation
import SwiftUI

class AppStorageContainer {
    static var main = AppStorageContainer()
    
    @AppStorage("username") var username: String = ""
    @AppStorage("groceryLists") var groceries: [GroceryList] = []
}

// MARK: Groceries
//extension AppStorageContainer {
//    private func hashRecipeToId(_ recipe: Recipe) -> String {
////        return String(recipe.hashValue)
//        return recipe.name
//    }
//    
//    private func getIngredientString(_ ingredient: Ingredient) -> String {
//        return ingredient.name + " (" + ingredient.quantity + " " + ingredient.unit +  ")"
//    }
//    
//    private func getIngredientId(_ ingredient: Ingredient) -> String {
//    }
//    
//    func createNewList(_ name: String) {
//        groceries.append(GroceryList(id: UUID().uuidString, name: name, items: []))
//    }
//    
//    func insertListFromRecipe(_ recipe: Recipe) {
//        if let listIndex = groceries.firstIndex(where: { $0.name == recipe.name }) {
//            
//        } else {
//            let groceryListItems = recipe.ingredients.map({ GroceryListItem(id: getIngredientId($0), ingredient: getIngredientString($0), check: false) })
//            groceries.append(GroceryList(id: UUID().uuidString, name: recipe.name, items: groceryListItems))
//        }
//    }
//    
//    func insertGroceryListItem(_ item: GroceryListItem, recipe: Recipe?) {
//        if let recipe = recipe {
//            var listIndex: Int
//            let listId = hashRecipeToId(recipe)
//
//            if let foundIndex = groceries.firstIndex(where: { $0.id == listId }) {
//                listIndex = foundIndex
//                groceries[listIndex].items.append(item)
//                groceries[listIndex].items = groceries[listIndex].items.sorted(by: { $0.ingredient < $1.ingredient })
//            } else {
//                groceries.append(GroceryList(id: listId, name: recipe.name, items: []))
//                listIndex = groceries.count - 1
//            }
//            
//            groceries[listIndex].items.append(item)
//            groceries[listIndex].items = groceries[listIndex].items.sorted(by: { $0.ingredient < $1.ingredient })
//        } else {
//            if groceries.isEmpty {
//                groceries.append(GroceryList(id: UUID().uuidString, name: "Main", items: []))
//            }
//            
//            groceries[0].items.append(item)
//            groceries[0].items = groceries[0].items.sorted(by: { $0.ingredient < $1.ingredient })
//        }
//    }
//    
//    func deleteCheckedItems() {
//        for index in 0..<groceries.count {
//            groceries[index].items = groceries[index].items.filter({ !$0.check })
//        }
//    }
//}
