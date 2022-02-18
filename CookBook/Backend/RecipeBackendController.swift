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

class RecipeBackendController {
    public static let url = BackendController.url + "recipes/"
    @AppStorage("token") var token: String = ""
    
    func loadNextRecipes(skip: Int, limit: Int, continuation: @escaping ([RecipeMeta]) -> Void) {
        var coordinate: CLLocationCoordinate2D? = nil
        var url = URLComponents(string: RecipeBackendController.url)!
        
        url.queryItems = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        var request = URLRequest(url: url.url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                continuation([])
                return
            }
            
            var recipes: [RecipeMetaBackendModel]?
            
            do {
                recipes = try JSONDecoder().decode([RecipeMetaBackendModel].self, from: data)
            } catch DecodingError.dataCorrupted(let context) {
                print(context)
            } catch DecodingError.keyNotFound(let key, let context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch DecodingError.valueNotFound(let value, let context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch DecodingError.typeMismatch(let type, let context) {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
            if let recipes = recipes {
                let recipeModels = recipes.map { recipeMeta -> RecipeMeta in
                    if let lat = Double(recipeMeta.recipe.coordinate_lat), let long = Double(recipeMeta.recipe.coordinate_long) {
                        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    }
                    
                    let recipeObject = Recipe(image: recipeMeta.recipe.image, name: recipeMeta.recipe.name, author: recipeMeta.recipe.author, ingredients: recipeMeta.recipe.ingredients, steps: recipeMeta.recipe.steps, coordinate: coordinate, emoji: recipeMeta.recipe.emoji, servings: recipeMeta.recipe.servings, tags: recipeMeta.recipe.tags, time: recipeMeta.recipe.time, specialTools: recipeMeta.recipe.specialTools)
                    return RecipeMeta(id: recipeMeta.id, recipe: recipeObject, rating: recipeMeta.rating, favorited: recipeMeta.favorited)
                }
                continuation(recipeModels)
            }
        }
        
        task.resume()
    }
    
    func loadAllRecipes(continuation: @escaping ([RecipeMeta]) -> Void) {
        var coordinate: CLLocationCoordinate2D? = nil
        let url = URL(string: RecipeBackendController.url)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                continuation([])
                return
            }
            
            var recipes: [RecipeMetaBackendModel]?
            
            do {
                recipes = try JSONDecoder().decode([RecipeMetaBackendModel].self, from: data)
            } catch DecodingError.dataCorrupted(let context) {
                print(context)
            } catch DecodingError.keyNotFound(let key, let context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch DecodingError.valueNotFound(let value, let context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch DecodingError.typeMismatch(let type, let context) {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
            if let recipes = recipes {
                let recipeModels = recipes.map { recipeMeta -> RecipeMeta in
                    if let lat = Double(recipeMeta.recipe.coordinate_lat), let long = Double(recipeMeta.recipe.coordinate_long) {
                        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    }
                    
                    let recipeObject = Recipe(image: recipeMeta.recipe.image, name: recipeMeta.recipe.name, author: recipeMeta.recipe.author, ingredients: recipeMeta.recipe.ingredients, steps: recipeMeta.recipe.steps, coordinate: coordinate, emoji: recipeMeta.recipe.emoji, servings: recipeMeta.recipe.servings, tags: recipeMeta.recipe.tags, time: recipeMeta.recipe.time, specialTools: recipeMeta.recipe.specialTools)
                    return RecipeMeta(id: recipeMeta.id, recipe: recipeObject, rating: recipeMeta.rating, favorited: recipeMeta.favorited)
                }
                continuation(recipeModels)
            }
        }
        
        task.resume()
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
        
        let url = URL(string: RecipeBackendController.url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let bearer = "Bearer " + token
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                continuation(false)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: String] {
                if let responseString = responseJSON["response"] {
                    continuation(responseString == "success")
                }
            } else {
                continuation(false)
            }
        }
        
        task.resume()
    }
}
