//
//  CookBookApp.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI
import MapKit

@main
struct CookBookApp: App {
    var body: some Scene {
        WindowGroup {
//            let coordinates_boba = CLLocationCoordinate2D(latitude: 34.058040, longitude: -118.466301)
//            let ingredients_boba = [
//                Ingredient(id: "0", name: "milk", quantity: "2", unit: "cup"),
//                Ingredient(id: "1", name: "tea", quantity: "1/2", unit: "cup"),
//                Ingredient(id: "2", name: "sugar", quantity: "2", unit: "tblsp")
//            ]
//            let steps_boba = [
//                "Mix sugar and tea",
//                "Add milk"
//            ]
//            let boba_recipe = Recipe(id: UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e")!, image: "simple_milk_tea", name: "Simple Milk Tea", author: "Micky Abir", rating: 4.5, ingredients: ingredients_boba, steps: steps_boba, coordinate: coordinates_boba, emoji: "🧋", favorited: 100, servings: 1)
//
//
//            let ingredients_coffee = [
//                Ingredient(id: "0", name: "ground espresso", quantity: "18", unit: "g"),
//                Ingredient(id: "1", name: "milk", quantity: "100", unit: "ml"),
//            ]
//
//            let steps_coffee = [
//                "Make around 35ml espresso using your coffee machine and pour into the base of your cup.",
//                "Steam the milk with the steamer attachment so that it has around 1-2cm of foam on top. Hold the jug so that the spout is about 3-4cm above the cup and pour the milk in steadily. As the volume within the cup increases, bring the jug as close to the surface of the drink as possible whilst aiming to pour into the centre. Once the milk jug is almost touching the surface of the coffee, tilt the jug to speed up the rate of pour. As you accelerate, the milk will hit the back of the cup and start naturally folding in on itself to create a pattern on the top."
//            ]
//
//            let coordinates_coffee = CLLocationCoordinate2D(latitude: 34.053578, longitude: -118.465992)
//            let coffee_recipe = Recipe(id: UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09f")!, image: "flat_white", name: "Flat White", author: "Kane Statton", rating: 5, ingredients: ingredients_coffee, steps: steps_coffee, coordinate: coordinates_coffee, emoji: "☕", favorited: 1000, servings: 1)
//
//
//            let ingredients_spaghetti = [
//                Ingredient(id: "0", name: "Barilla® Pronto® Half-Cut Spaghetti", quantity: "12", unit: "oz"),
//                Ingredient(id: "1", name: "salt", quantity: "1", unit: "pinch"),
//                Ingredient(id: "2", name: "ground beef", quantity: "1", unit: "lb"),
//                Ingredient(id: "3", name: "Barilla® Tomato and Basil Sauce", quantity: "24", unit: "oz"),
//            ]
//
//            let steps_spaghetti = [
//                "To a large pan, add the pasta, cover with 3 cups cold water, optional salt to taste, and boil over high heat until water has absorbed, about 10 minutes, but watch your pasta and cook as needed until al dente. While pasta boils, brown the ground beef.",
//                "To a large skillet, add the ground beef and cook over medium-high heat, breaking up the meat with a spatula as it cooks to ensure even cooking.",
//                "After beef has cooked through, add the pasta sauce, stir to combine, and cook for 1 to 2 minutes, or until heated through.",
//                "After pasta has cooked for about 10 minutes, or until all the water has been absorbed, add the sauce over the pasta and toss to combine in the skillet or alternatively plate the pasta and add sauce to each individual plate as desired.",
//                "Optionally garnish with basil and Parmesan to taste and serve immediately. Pasta and sauce are best warm and fresh but extra will keep airtight in the fridge for up to 5 days."
//            ]
//
//            let coordinates_spaghetti = CLLocationCoordinate2D(latitude: 34.047, longitude: -118.454)
//            let spaghetti_recipe = Recipe(id: UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09d")!, image: "spaghetti", name: "Easy Spaghetti", author: "Averie Sunshine", rating: 4.6, ingredients: ingredients_spaghetti, steps: steps_spaghetti, coordinate: coordinates_spaghetti, emoji: "🍝", favorited: 5000, servings: 4)

            
            
//            let recipes = [boba_recipe, coffee_recipe, spaghetti_recipe]
            let recipes = [Recipe]()
            ContentView(recipes: recipes)
                .preferredColorScheme(.light)
        }
    }
}
