//
//  NewRecipeUploader.swift
//  CookBook
//
//  Created by Michael Abir on 1/26/22.
//

import Foundation

class RecipeBackendController {
    private let url = "http://127.0.0.1:8000/recipes/"
    
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

        // create post request
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                continuation(false)
                return
            }
//            if let response = response as? HTTPURLResponse {
//                continuation(response.statusCode == 200)
//            }
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
