//
//  UserBackendController.swift
//  CookBook
//
//  Created by Michael Abir on 2/17/22.
//

import Foundation
import CoreLocation
import SwiftUI

struct UserBackendModel: Codable {
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

struct AccessTokenModel: Codable {
    var access_token: String
}

struct SuccessResponse: Codable {
    var success: Bool
}

class UserBackendController {
    public static let url = BackendController.url + "users/"
    @AppStorage("token") var token: String = ""
    
    func verifyToken(continuation: @escaping (Bool) -> Void) {
        let url = URLComponents(string: BackendController.url + "auth/verify")!
                
        var request = URLRequest(url: url.url!)
        request.httpMethod = "GET"
        
        let bearer = "Bearer " + token
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                continuation(false)
                return
            }
            
            var success: SuccessResponse?
            
            do {
                success = try JSONDecoder().decode(SuccessResponse.self, from: data)
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
            if let success = success {
                continuation(success.success)
            }
        }
        
        task.resume()
    }
    
    func signIn(username: String, password: String, continuation: @escaping (String?) -> Void) {
        let url = URLComponents(string: UserBackendController.url + "signin")!
                
        var request = URLRequest(url: url.url!)
        request.httpMethod = "POST"
        
        let parameters: [String: String] = [
            "username": username,
            "password": password
        ]
                
        var jsonData: Data?
        do {
            jsonData = try JSONEncoder().encode(parameters)
        } catch {
            print(error)
        }
        
        guard let jsonData = jsonData else {
            continuation(nil)
            return
        }
        
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                continuation(nil)
                return
            }
            
            var token: AccessTokenModel?
            
            do {
                token = try JSONDecoder().decode(AccessTokenModel.self, from: data)
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
            if let token = token {
                continuation(token.access_token)
            } else {
                continuation(nil)
            }
        }
        
        task.resume()
    }
    
    func signUp(name: String, username: String, password: String, continuation: @escaping (String?) -> Void) {
        let url = URLComponents(string: UserBackendController.url + "signup")!
                
        var request = URLRequest(url: url.url!)
        request.httpMethod = "POST"
        
        let parameters: [String: String] = [
            "name": name,
            "username": username,
            "password": password
        ]
                
        var jsonData: Data?
        do {
            jsonData = try JSONEncoder().encode(parameters)
        } catch {
            print(error)
        }
        
        guard let jsonData = jsonData else {
            continuation(nil)
            return
        }
        
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                continuation(nil)
                return
            }
            
            var token: AccessTokenModel?
            
            do {
                token = try JSONDecoder().decode(AccessTokenModel.self, from: data)
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
            if let token = token {
                continuation(token.access_token)
            }
        }
        
        task.resume()
    }
}
