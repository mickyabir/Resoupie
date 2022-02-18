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
    var name: String
    var username: String
    var followers: Int
}

struct AccessTokenModel: Codable {
    var access_token: String
}

class UserBackendController: BackendControllable {
    internal let path = "users/"
    
    func verifyToken(continuation: @escaping (Bool) -> Void) {
        let backendController = BackendController()
        backendController.authorizedRequest(path: "auth/verify", method: "GET", modelType: SuccessResponse.self) { response in
            continuation(response?.success ?? false)
        }
    }
    
    func getUser(continuation: @escaping (User?) -> Void) {
        let backendController = BackendController()
        backendController.authorizedRequest(path: path + "me/", method: "GET", modelType: UserBackendModel.self) { user in
            if let user = user {
                continuation(User(name: user.name, username: user.username, followers: user.followers))
            } else {
                continuation(nil)
            }
        }
    }
    
    func signIn(username: String, password: String, continuation: @escaping (String?) -> Void) {
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
        
        let backendController = BackendController()
        backendController.authorizedRequest(path: path + "signin", method: "POST", modelType: AccessTokenModel.self, body: jsonData, contentType: .json) { token in
            continuation(token?.access_token ?? "")
        }
    }
    
    func signUp(name: String, username: String, password: String, continuation: @escaping (String?) -> Void) {
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
        
        let backendController = BackendController()
        backendController.authorizedRequest(path: path + "signup", method: "POST", modelType: AccessTokenModel.self, body: jsonData, contentType: .json) { token in
            continuation(token?.access_token ?? "")
        }
    }
}
