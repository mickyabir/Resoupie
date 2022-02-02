//
//  NewRecipeUploader.swift
//  CookBook
//
//  Created by Michael Abir on 1/26/22.
//

import Foundation
import CoreLocation

struct RecipeBackendModel: Codable {
    var id: String
    var image: String
    var name: String
    var author: String
    var ingredients: [Ingredient]
    var steps: [String]
    var emoji: String
    var servings: Int
    var rating: Double
    var favorited: Int
    var coordinate_lat: String
    var coordinate_long: String
}

class RecipeBackendController {
    public static let url = BackendController.url + "recipes/"
    
    func loadAllRecipes(continuation: @escaping ([Recipe]) -> Void) {
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
            
            var recipes: [RecipeBackendModel]?
            
            do {
                recipes = try JSONDecoder().decode([RecipeBackendModel].self, from: data)
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
                let recipeModels = recipes.map { recipe -> Recipe in
                    if let lat = Double(recipe.coordinate_lat), let long = Double(recipe.coordinate_long) {
                        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    }
                    
                    return Recipe(id: UUID(uuidString: recipe.id)!, image: recipe.image, name: recipe.name, author: recipe.author, rating: recipe.rating, ingredients: recipe.ingredients, steps: recipe.steps, coordinate: coordinate, emoji: recipe.emoji, favorited: recipe.favorited, servings: recipe.servings)
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
        let recipeModel = RecipeBackendModel(id: recipe.id.uuidString, image: recipe.image, name: recipe.name, author: recipe.author, ingredients: recipe.ingredients, steps: recipe.steps, emoji: recipe.emoji, servings: recipe.servings, rating: 0, favorited: 0, coordinate_lat: lat, coordinate_long: long)
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
