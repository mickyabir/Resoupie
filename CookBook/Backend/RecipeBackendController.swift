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
    var coordinate_lat: Double?
    var coordinate_long: Double?
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
    func getRecipesWorld(position: CLLocationCoordinate2D, latDelta: Double, longDelta: Double) -> AnyPublisher<[RecipeMeta], Error>
    func getUserFavorites() -> AnyPublisher<[RecipeMeta], Error>
    func getUserRecipes(username: String) -> AnyPublisher<[RecipeMeta], Error>
    func getRecipeById(recipe_id: String) -> AnyPublisher<RecipeMeta, Error>
    func rateRecipe(recipe_id: String, rating: Int) -> AnyPublisher<Bool, Error>
    func favoriteRecipe(recipe_id: String) -> AnyPublisher<Bool, Error>
    func unfavoriteRecipe(recipe_id: String) -> AnyPublisher<Bool, Error>
    func loadNextRecipes(skip: Int, limit: Int) -> AnyPublisher<[RecipeMeta], Error>
    func loadAllRecipes() -> AnyPublisher<[RecipeMeta], Error>
    func uploadRecipeToServer(recipe: Recipe) -> AnyPublisher<Bool, Error>
}

extension BackendController: RecipeBackendController {
    internal struct RecipeBackend {
        static let path = "recipes/"
    }
    
    func getRecipesWorld(position: CLLocationCoordinate2D, latDelta: Double, longDelta: Double) -> AnyPublisher<[RecipeMeta], Error> {
        let params = [
            URLQueryItem(name: "coordinate_lat", value: String(position.latitude)),
            URLQueryItem(name: "coordinate_long", value: String(position.longitude)),
            URLQueryItem(name: "lat_delta", value: String(latDelta)),
            URLQueryItem(name: "long_delta", value: String(longDelta)),
        ]
        return request(path: RecipeBackend.path + "world", method: "GET", modelType: [RecipeMetaBackendModel].self, params: params)
            .tryMap { recipeModels in
                return self.mapRecipeMetas(recipeModels: recipeModels)
            }
            .eraseToAnyPublisher()
    }
    
    func getUserRecipes(username: String) -> AnyPublisher<[RecipeMeta], Error> {
        let params = [
            URLQueryItem(name: "username", value: String(username)),
        ]
        return authorizedRequest(path: RecipeBackend.path, method: "GET", modelType: [RecipeMetaBackendModel].self, params: params)
            .tryMap { recipeModels in
                return self.mapRecipeMetas(recipeModels: recipeModels)
            }
            .eraseToAnyPublisher()
    }
    
    func getRecipeById(recipe_id: String) -> AnyPublisher<RecipeMeta, Error> {
        return authorizedRequest(path: RecipeBackend.path + "get/" + recipe_id, method: "GET", modelType: RecipeMetaBackendModel.self)
            .tryMap { recipeModel in
                return self.mapRecipeMeta(recipeModel: recipeModel)
            }
            .eraseToAnyPublisher()
    }
    
    func getUserFavorites() -> AnyPublisher<[RecipeMeta], Error> {
        return authorizedRequest(path: RecipeBackend.path + "favorites", method: "GET", modelType: [RecipeMetaBackendModel].self)
            .tryMap { recipeModels in
                return self.mapRecipeMetas(recipeModels: recipeModels)
            }
            .eraseToAnyPublisher()
    }
    
    func rateRecipe(recipe_id: String, rating: Int) -> AnyPublisher<Bool, Error> {
        let params = [
            URLQueryItem(name: "rating", value: String(rating)),
        ]
        
        return authorizedRequest(path: RecipeBackend.path + recipe_id, method: "POST", modelType: SuccessResponse.self, params: params)
            .tryMap { response in
                response.success
            }
            .eraseToAnyPublisher()
    }

    func favoriteRecipe(recipe_id: String) -> AnyPublisher<Bool, Error> {
        return authorizedRequest(path: RecipeBackend.path + recipe_id + "/favorite", method: "POST", modelType: SuccessResponse.self)
            .tryMap { response in
                return response.success
            }
            .eraseToAnyPublisher()
    }
    
    func unfavoriteRecipe(recipe_id: String) -> AnyPublisher<Bool, Error> {
        return authorizedRequest(path: RecipeBackend.path + recipe_id + "/unfavorite", method: "POST", modelType: SuccessResponse.self)
            .tryMap { response in
                return response.success
            }
            .eraseToAnyPublisher()
    }
    
    func loadNextRecipes(skip: Int, limit: Int) -> AnyPublisher<[RecipeMeta], Error> {
        let params = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        return request(path: RecipeBackend.path, method: "GET", modelType: [RecipeMetaBackendModel].self, params: params)
            .tryMap { recipes in
                return self.mapRecipeMetas(recipeModels: recipes)
            }
            .eraseToAnyPublisher()
    }
    
    func loadAllRecipes() -> AnyPublisher<[RecipeMeta], Error> {
        return request(path: RecipeBackend.path, method: "GET", modelType: [RecipeMetaBackendModel].self)
            .tryMap { recipes in
                return self.mapRecipeMetas(recipeModels: recipes)
            }
            .eraseToAnyPublisher()
    }
    
    func uploadRecipeToServer(recipe: Recipe) -> AnyPublisher<Bool, Error> {
        var lat: Double? = nil
        var long: Double? = nil
        if let coordinate = recipe.coordinate {
            lat = Double(coordinate.latitude)
            long = Double(coordinate.longitude)
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
        
        return authorizedRequest(path: RecipeBackend.path, method: "POST", modelType: SuccessResponse.self, body: jsonData, contentType: .json)
            .tryMap { response in
                response.success
            }
            .eraseToAnyPublisher()
    }
    
    private func mapRecipeMeta(recipeModel: RecipeMetaBackendModel) -> RecipeMeta {
        var coordinate: CLLocationCoordinate2D? = nil
        if let lat = recipeModel.recipe.coordinate_lat, let long = recipeModel.recipe.coordinate_long {
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        let recipeObject = Recipe(image: recipeModel.recipe.image, name: recipeModel.recipe.name, author: recipeModel.recipe.author, ingredients: recipeModel.recipe.ingredients, steps: recipeModel.recipe.steps, coordinate: coordinate, emoji: recipeModel.recipe.emoji, servings: recipeModel.recipe.servings, tags: recipeModel.recipe.tags, time: recipeModel.recipe.time, specialTools: recipeModel.recipe.specialTools)
        return RecipeMeta(id: recipeModel.id, recipe: recipeObject, rating: recipeModel.rating, favorited: recipeModel.favorited)

    }
    
    private func mapRecipeMetas(recipeModels: [RecipeMetaBackendModel]) -> [RecipeMeta] {
        let recipeModels = recipeModels.map(mapRecipeMeta)
        return recipeModels
    }
}
