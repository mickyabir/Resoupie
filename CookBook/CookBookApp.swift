//
//  CookBookApp.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI

@main
struct CookBookApp: App {
    var body: some Scene {
        WindowGroup {
            let ingredients = [
                Ingredient(id: 0, name: "milk", quantity: "2", unit: "cup"),
                Ingredient(id: 1, name: "tea", quantity: "1/2", unit: "cup"),
                Ingredient(id: 2, name: "sugar", quantity: "2", unit: "tblsp")
            ]
            let steps = [
                "Mix sugar and tea",
                "Add milk"
            ]
            let boba_recipe = Recipe(id: UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e")!, name: "boba", author: "Micky Abir", rating: 4.5, ingredients: ingredients, steps: steps)
            let recipes = [boba_recipe]
            ContentView(recipes: recipes)
        }
    }
}
