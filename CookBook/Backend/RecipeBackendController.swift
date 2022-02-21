//
//  NewRecipeUploader.swift
//  CookBook
//
//  Created by Michael Abir on 1/26/22.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

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

enum RecipeError: Error {
    
}

protocol RecipeBackendController {
    func getUserRecipesCombine(username: String) -> AnyPublisher<[RecipeMeta], Error>
    func rateRecipeCombine(recipe_id: String, rating: Int) -> AnyPublisher<Bool, Error>
    func favoriteRecipeCombine(recipe_id: String) -> AnyPublisher<Bool, Error>
    func unfavoriteRecipeCombine(recipe_id: String) -> AnyPublisher<Bool, Error>
    func loadNextRecipesCombine(skip: Int, limit: Int) -> AnyPublisher<[RecipeMeta], Error>
    func loadAllRecipesCombine() -> AnyPublisher<[RecipeMeta], Error>
    func uploadRecipeToServerCombine(recipe: Recipe) -> AnyPublisher<Bool, Error>
}

extension BackendController: RecipeBackendController {
    internal struct RecipeBackend {
        static let path = "recipes/"
    }
    
    func getUserRecipesCombine(username: String) -> AnyPublisher<[RecipeMeta], Error> {
        return authorizedRequestCombine(path: RecipeBackend.path + username, method: "GET", modelType: [RecipeMetaBackendModel].self)
            .tryMap { recipeModels in
                return self.mapRecipeMetas(recipes: recipeModels)
            }
            .eraseToAnyPublisher()
    }
    
    func rateRecipeCombine(recipe_id: String, rating: Int) -> AnyPublisher<Bool, Error> {
        let params = [
            URLQueryItem(name: "rating", value: String(rating)),
        ]
        
        return authorizedRequestCombine(path: RecipeBackend.path + recipe_id, method: "POST", modelType: SuccessResponse.self, params: params)
            .tryMap { response in
                response.success
            }
            .eraseToAnyPublisher()
    }

    func favoriteRecipeCombine(recipe_id: String) -> AnyPublisher<Bool, Error> {
        return authorizedRequestCombine(path: RecipeBackend.path + recipe_id + "/favorite", method: "POST", modelType: SuccessResponse.self)
            .tryMap { response in
                return response.success
            }
            .eraseToAnyPublisher()
    }
    
    func unfavoriteRecipeCombine(recipe_id: String) -> AnyPublisher<Bool, Error> {
        return authorizedRequestCombine(path: RecipeBackend.path + recipe_id + "/unfavorite", method: "POST", modelType: SuccessResponse.self)
            .tryMap { response in
                return response.success
            }
            .eraseToAnyPublisher()
    }
    
    func loadNextRecipesCombine(skip: Int, limit: Int) -> AnyPublisher<[RecipeMeta], Error> {
        let params = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        return authorizedRequestCombine(path: RecipeBackend.path, method: "GET", modelType: [RecipeMetaBackendModel].self, params: params)
            .tryMap { recipes in
                return self.mapRecipeMetas(recipes: recipes)
            }
            .eraseToAnyPublisher()
    }
    
    func loadAllRecipesCombine() -> AnyPublisher<[RecipeMeta], Error> {
        return authorizedRequestCombine(path: RecipeBackend.path, method: "GET", modelType: [RecipeMetaBackendModel].self)
            .tryMap { recipes in
                return self.mapRecipeMetas(recipes: recipes)
            }
            .eraseToAnyPublisher()
    }
    
    func uploadRecipeToServerCombine(recipe: Recipe) -> AnyPublisher<Bool, Error> {
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
            return Empty<Bool, Error>(completeImmediately: true).eraseToAnyPublisher()
        }
        
        return authorizedRequestCombine(path: RecipeBackend.path, method: "POST", modelType: SuccessResponse.self, body: jsonData, contentType: .json)
            .tryMap { response in
                response.success
            }
            .eraseToAnyPublisher()
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
