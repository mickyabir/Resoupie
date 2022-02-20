//
//  UserBackendController.swift
//  CookBook
//
//  Created by Michael Abir on 2/17/22.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

struct UserBackendModel: Codable {
    var name: String
    var username: String
    var followers: Int
}

struct AccessTokenModel: Codable {
    var access_token: String
}

enum UserError: Error {
    case invalid
}


protocol UserBackendController {
    func verifyToken(continuation: @escaping (Bool) -> Void)
    func getUserCombine() -> AnyPublisher<User, Error>
    func getUser(continuation: @escaping (User?) -> Void)
    func signIn(username: String, password: String, continuation: @escaping (String?) -> Void)
    func signUp(name: String, username: String, password: String, continuation: @escaping (String?) -> Void)
}


extension BackendController: UserBackendController {
    internal struct UserBackend {
        static let path = "users/"
    }
    
    func verifyToken(continuation: @escaping (Bool) -> Void) {
        let backendController = BackendController()
        backendController.authorizedRequest(path: "auth/verify", method: "GET", modelType: SuccessResponse.self) { response in
            continuation(response?.success ?? false)
        }
    }
    
    func getUserCombine() -> AnyPublisher<User, Error> {
        let backendController = BackendController()
        return backendController.authorizedRequestCombine(path: UserBackend.path + "me/", method: "GET", modelType: UserBackendModel.self)
            .tryMap { user in
                return User(name: user.name, username: user.username, followers: user.followers)
            }
            .eraseToAnyPublisher()
    }
    
    func getUser(continuation: @escaping (User?) -> Void) {
        let backendController = BackendController()
        backendController.authorizedRequest(path: UserBackend.path + "me/", method: "GET", modelType: UserBackendModel.self) { user in
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
        backendController.authorizedRequest(path: UserBackend.path + "signin", method: "POST", modelType: AccessTokenModel.self, body: jsonData, contentType: .json) { token in
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
        backendController.authorizedRequest(path: UserBackend.path + "signup", method: "POST", modelType: AccessTokenModel.self, body: jsonData, contentType: .json) { token in
            continuation(token?.access_token ?? "")
        }
    }
}
