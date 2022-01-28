//
//  NewRecipeUploader.swift
//  CookBook
//
//  Created by Michael Abir on 1/26/22.
//

import Foundation

struct Coordinate: Codable {
    var long: Double
    var lat: Double
}

struct RecipeListResponse: Codable {
    var id: String
    var image: String
    var name: String
    var author: String
    var ingredients: [Ingredient]
    var steps: [String]
    var coordinate: Coordinate
    var emoji: String
    var servings: Int
    var rating: Double
    var favorited: Int
}

class RecipeBackendController {
    private let url = BackendController.url + "recipes/"
    
    func loadAllRecipes(continuation: @escaping ([Recipe]) -> Void) {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                continuation([])
                return
            }
            
            var recipes: [RecipeListResponse]?
            
            do {
                recipes = try JSONDecoder().decode([RecipeListResponse].self, from: data)
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
                let recipeModels = recipes.map { recipe in
                    Recipe(id: UUID(uuidString: recipe.id)!, image: recipe.image, name: recipe.name, author: recipe.author, rating: recipe.rating, ingredients: recipe.ingredients, steps: recipe.steps, coordinate: nil, emoji: recipe.emoji, favorited: recipe.favorited, servings: recipe.servings)
                }
                continuation(recipeModels)
            }
        }
        
        task.resume()
    }
    
    func uploadRecipeToServer(recipe: Recipe, continuation: @escaping (Bool) -> Void) {
        var jsonData: Data?
        do {
            jsonData = try JSONEncoder().encode(recipe)
        } catch {
            print(error)
        }
        
        guard let jsonData = jsonData else {
            continuation(false)
            return
        }
        
        let url = URL(string: url)!
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
                continuation(responseJSON["response"] == "success")
            } else {
                continuation(false)
            }
        }
        
        task.resume()
    }
}
