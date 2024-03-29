//
//  NewRecipeUploader.swift
//  Resoupie
//
//  Created by Michael Abir on 1/26/22.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

struct ForkInfoModel: Codable {
    var parent_name: String
    var parent_author: String
    var parent_id: String
}

struct RecipeRateResponse: Codable {
    var success: Bool
    var rating: Double
}

struct IntegerResponse: Codable {
    var num: Int
}

protocol RecipeBackendController {
    func getRecipesWorld(position: CLLocationCoordinate2D, latDelta: Double, longDelta: Double) -> AnyPublisher<[RecipeMeta], Error>
    func getUserFavorites() -> AnyPublisher<[RecipeMeta], Error>
    func getUserIdRecipes(user_id: String) -> AnyPublisher<[RecipeMeta], Error>
    func getUserRecipes(username: String) -> AnyPublisher<[RecipeMeta], Error>
    func getRecipeById(recipe_id: String) -> AnyPublisher<RecipeMeta, Error>
    func rateRecipe(recipe_id: String, rating: Int) -> AnyPublisher<Double, Error>
    func favoriteRecipe(recipe_id: String) -> AnyPublisher<Bool, Error>
    func unfavoriteRecipe(recipe_id: String) -> AnyPublisher<Bool, Error>
    func loadNextRecipes(skip: Int, limit: Int) -> AnyPublisher<[RecipeMeta], Error>
    func loadPopularRecipes(skip: Int, limit: Int) -> AnyPublisher<[RecipeMeta], Error>
    func loadCategoryRecipesPopular(category: String, skip: Int, limit: Int) -> AnyPublisher<[RecipeMeta], Error>
    func loadDefaultPageRecipes() -> AnyPublisher<[String:[RecipeMeta]], Error>
    func loadAllRecipes() -> AnyPublisher<[RecipeMeta], Error>
    func getForkInfo(recipe_id: String) -> AnyPublisher<ForkInfoModel, Error>
    func viewRecipe(recipe_id: String) -> AnyPublisher<SuccessResponse, Error>
    func getForkChildren(recipe_id: String) -> AnyPublisher<[RecipeMeta], Error>
    func uploadRecipeToServer(recipe: Recipe) -> AnyPublisher<Bool, Error>
    func searchRecipes(searchString: String, limit: Int) -> AnyPublisher<[RecipeMeta], Error>
    func userCookedRecipe(recipe_id: String) -> AnyPublisher<Bool, Error>
    func getUserCookedCount(recipe_id: String) -> AnyPublisher<Int, Error>
}


extension RecipeBackendController {
    func searchRecipes(searchString: String) -> AnyPublisher<[RecipeMeta], Error> {
        return searchRecipes(searchString: searchString, limit: 10)
    }
}

extension BackendController: RecipeBackendController {
    internal struct RecipeBackend {
        static let path = "recipes/"
    }
    
    func viewRecipe(recipe_id: String) -> AnyPublisher<SuccessResponse, Error> {
        return authorizedRequest(path: RecipeBackend.path + recipe_id + "/view", method: "POST", modelType: SuccessResponse.self)
            .eraseToAnyPublisher()
    }
    
    func getForkInfo(recipe_id: String) -> AnyPublisher<ForkInfoModel, Error> {
        return authorizedRequest(path: RecipeBackend.path + recipe_id + "/parent", method: "GET", modelType: ForkInfoModel.self)
            .eraseToAnyPublisher()
    }
    
    func getForkChildren(recipe_id: String) -> AnyPublisher<[RecipeMeta], Error> {
        return authorizedRequest(path: RecipeBackend.path + recipe_id + "/children", method: "GET", modelType: [RecipeMeta].self)
            .eraseToAnyPublisher()
    }
    
    func getRecipesWorld(position: CLLocationCoordinate2D, latDelta: Double, longDelta: Double) -> AnyPublisher<[RecipeMeta], Error> {
        let params = [
            URLQueryItem(name: "coordinate_lat", value: String(position.latitude)),
            URLQueryItem(name: "coordinate_long", value: String(position.longitude)),
            URLQueryItem(name: "lat_delta", value: String(latDelta)),
            URLQueryItem(name: "long_delta", value: String(longDelta)),
        ]
        return request(path: RecipeBackend.path + "world", method: "GET", modelType: [RecipeMeta].self, params: params)
            .eraseToAnyPublisher()
    }

    func getUserIdRecipes(user_id: String) -> AnyPublisher<[RecipeMeta], Error> {
        let params = [
            URLQueryItem(name: "user_id", value: String(user_id)),
        ]
        return authorizedRequest(path: RecipeBackend.path + "user_id", method: "GET", modelType: [RecipeMeta].self, params: params)
            .eraseToAnyPublisher()
    }
    
    func getUserRecipes(username: String) -> AnyPublisher<[RecipeMeta], Error> {
        let params = [
            URLQueryItem(name: "username", value: String(username)),
        ]
        return authorizedRequest(path: RecipeBackend.path + "username", method: "GET", modelType: [RecipeMeta].self, params: params)
            .eraseToAnyPublisher()
    }
    
    func getRecipeById(recipe_id: String) -> AnyPublisher<RecipeMeta, Error> {
        return authorizedRequest(path: RecipeBackend.path + "get/" + recipe_id, method: "GET", modelType: RecipeMeta.self)
            .eraseToAnyPublisher()
    }
    
    func getUserFavorites() -> AnyPublisher<[RecipeMeta], Error> {
        return authorizedRequest(path: RecipeBackend.path + "favorites", method: "GET", modelType: [RecipeMeta].self)
            .eraseToAnyPublisher()
    }
    
    func rateRecipe(recipe_id: String, rating: Int) -> AnyPublisher<Double, Error> {
        let params = [
            URLQueryItem(name: "rating", value: String(rating)),
        ]
        
        return authorizedRequest(path: RecipeBackend.path + recipe_id + "/rate", method: "POST", modelType: RecipeRateResponse.self, params: params)
            .tryMap { response in
                response.rating
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
        
        return request(path: RecipeBackend.path + "get", method: "GET", modelType: [RecipeMeta].self, params: params)
            .eraseToAnyPublisher()
    }
    
    func loadPopularRecipes(skip: Int, limit: Int) -> AnyPublisher<[RecipeMeta], Error> {
        let params = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        return request(path: RecipeBackend.path + "popular", method: "GET", modelType: [RecipeMeta].self, params: params)
            .eraseToAnyPublisher()
    }
    
    func loadCategoryRecipesPopular(category: String, skip: Int, limit: Int) -> AnyPublisher<[RecipeMeta], Error> {
        let params = [
            URLQueryItem(name: "category", value: String(category)),
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        return request(path: RecipeBackend.path + "category", method: "GET", modelType: [RecipeMeta].self, params: params)
            .eraseToAnyPublisher()
    }
    
    func loadDefaultPageRecipes() -> AnyPublisher<[String:[RecipeMeta]], Error> {
        return authorizedRequest(path: RecipeBackend.path + "default", method: "GET", modelType: [String:[RecipeMeta]].self)
            .eraseToAnyPublisher()
    }
    
    func loadAllRecipes() -> AnyPublisher<[RecipeMeta], Error> {
        return request(path: RecipeBackend.path + "get", method: "GET", modelType: [RecipeMeta].self)
            .eraseToAnyPublisher()
    }
    
    func uploadRecipeToServer(recipe: Recipe) -> AnyPublisher<Bool, Error> {
        var jsonData: Data?
        do {
            jsonData = try JSONEncoder().encode(recipe)
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
    
    func editRecipe(recipe: Recipe, recipe_id: String) -> AnyPublisher<Bool, Error> {
        var jsonData: Data?
        do {
            jsonData = try JSONEncoder().encode(recipe)
        } catch {
            print(error)
        }
        
        let params = [
            URLQueryItem(name: "recipe_id", value: recipe_id)
        ]

                
        guard let jsonData = jsonData else {
            return Empty<Bool, Error>(completeImmediately: true).eraseToAnyPublisher()
        }
        
        return authorizedRequest(path: RecipeBackend.path + recipe_id + "/edit", method: "POST", modelType: SuccessResponse.self, params: params, body: jsonData, contentType: .json)
            .tryMap { response in
                response.success
            }
            .eraseToAnyPublisher()
    }
    
    func searchRecipes(searchString: String, limit: Int) -> AnyPublisher<[RecipeMeta], Error> {
        let params = [
            URLQueryItem(name: "search_string", value: searchString),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        return request(path: RecipeBackend.path + "search", method: "GET", modelType: [RecipeMeta].self, params: params)
            .eraseToAnyPublisher()
    }
    
    func userCookedRecipe(recipe_id: String) -> AnyPublisher<Bool, Error> {
        return authorizedRequest(path: RecipeBackend.path + recipe_id + "/cooked", method: "POST", modelType: SuccessResponse.self)
            .map { response in
                return response.success
            }
            .eraseToAnyPublisher()
    }
    
    func getUserCookedCount(recipe_id: String) -> AnyPublisher<Int, Error> {
        return authorizedRequest(path: RecipeBackend.path + recipe_id + "/cooked_count", method: "GET", modelType: IntegerResponse.self)
            .map { response in
                return response.num
            }
            .eraseToAnyPublisher()
    }
}
