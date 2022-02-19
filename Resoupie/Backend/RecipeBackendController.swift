//
//  NewRecipeUploader.swift
//  CookBook
//
//  Created by Michael Abir on 1/26/22.
//

import Foundation
import CoreLocation
import SwiftUI

struct RecipeBackendModel: Codable {
    var image: String
    var name: String
    var author: String
    var ingredients: [Ingredient]
    var steps: [String]
    var emoji: String
    var servings: Int
    var coordinate_lat: String
    var coordinate_long: String
    var tags: [String]
    var time: String
    var specialTools: [String]
}

struct RecipeMetaBackendModel: Codable {
    var id: String
    var recipe: RecipeBackendModel
    var rating: Double
    var favorited: Int
}

class RecipeBackendController: BackendControllable {
    internal let path = "recipes/"
    
    func getUserRecipes(username: String, continuation: @escaping ([RecipeMeta]?) -> Void) {
        let backendController = BackendController()
        backendController.authorizedRequest(path: path + username, method: "GET", modelType: [RecipeMetaBackendModel].self) { recipes in
            if let recipes = recipes {
                continuation(self.mapRecipeMetas(recipes: recipes))
            } else {
                continuation(nil)
            }
        }
    }
    
    func rateRecipe(recipe_id: String, rating: Int) {
        let backendController = BackendController()
        
        let params = [
            URLQueryItem(name: "rating", value: String(rating)),
        ]
        
        backendController.authorizedRequest(path: path + recipe_id, method: "POST", modelType: SuccessResponse.self, params: params) { response in
        }
    }
    
    func favoriteRecipe(recipe_id: String) {
        let backendController = BackendController()
        
        backendController.authorizedRequest(path: path + recipe_id + "/favorite", method: "POST", modelType: SuccessResponse.self) { response in
        }
    }
    
    func unfavoriteRecipe(recipe_id: String) {
        let backendController = BackendController()
        
        backendController.authorizedRequest(path: path + recipe_id + "/unfavorite", method: "POST", modelType: SuccessResponse.self) { response in
        }
    }
    
    func loadNextRecipes(skip: Int, limit: Int, continuation: @escaping ([RecipeMeta]) -> Void) {
        let backendController = BackendController()

        let params = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        backendController.authorizedRequest(path: path, method: "GET", modelType: [RecipeMetaBackendModel].self, params: params) { recipes in
            if let recipes = recipes {
                continuation(self.mapRecipeMetas(recipes: recipes))
            } else {
                continuation([])
            }
        }
        
    }
    
    func loadAllRecipes(continuation: @escaping ([RecipeMeta]) -> Void) {
        let backendController = BackendController()
        
        backendController.authorizedRequest(path: path, method: "GET", modelType: [RecipeMetaBackendModel].self) { recipes in
            if let recipes = recipes {
                continuation(self.mapRecipeMetas(recipes: recipes))
            } else {
                continuation([])
            }
        }
    }
    
    func uploadRecipeToServer(recipe: Recipe, continuation: @escaping (Bool) -> Void) {
        var lat = ""
        var long = ""
        if let coordinate = recipe.coordinate {
            lat = String(coordinate.latitude)
            long = String(coordinate.longitude)
        }
        let recipeModel = RecipeBackendModel(image: recipe.image, name: recipe.name, author: recipe.author, ingredients: recipe.ingredients, steps: recipe.steps, emoji: recipe.emoji, servings: recipe.servings, coordinate_lat: lat, coordinate_long: long, tags: recipe.tags, time: recipe.time, specialTools: recipe.specialTools)
        
        var jsonData: Data?
        do {
            jsonData = try JSONEncoder().encode(recipeModel)
        } catch {
            print(error)
        }
                
        guard let jsonData = jsonData else {
            continuation(false)
            return
        }
        
        let backendController = BackendController()
        backendController.authorizedRequest(path: "recipes/", method: "POST", modelType: SuccessResponse.self, body: jsonData, contentType: .json) { response in
            continuation(response?.success ?? false)
        }
    }
    
    private func mapRecipeMetas(recipes: [RecipeMetaBackendModel]) -> [RecipeMeta] {
        var coordinate: CLLocationCoordinate2D? = nil
        let recipeModels = recipes.map { recipeMeta -> RecipeMeta in
            if let lat = Double(recipeMeta.recipe.coordinate_lat), let long = Double(recipeMeta.recipe.coordinate_long) {
                coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
            
            let recipeObject = Recipe(image: recipeMeta.recipe.image, name: recipeMeta.recipe.name, author: recipeMeta.recipe.author, ingredients: recipeMeta.recipe.ingredients, steps: recipeMeta.recipe.steps, coordinate: coordinate, emoji: recipeMeta.recipe.emoji, servings: recipeMeta.recipe.servings, tags: recipeMeta.recipe.tags, time: recipeMeta.recipe.time, specialTools: recipeMeta.recipe.specialTools)
            return RecipeMeta(id: recipeMeta.id, recipe: recipeObject, rating: recipeMeta.rating, favorited: recipeMeta.favorited)
        }
        return recipeModels
    }
}
