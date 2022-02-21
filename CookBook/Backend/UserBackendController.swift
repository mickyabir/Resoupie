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
    func verifyToken() -> AnyPublisher<Bool, Error>
    func getUser() -> AnyPublisher<User, Error>
    func signIn(username: String, password: String) -> AnyPublisher<String, Error>
    func signUp(name: String, username: String, password: String) -> AnyPublisher<String, Error>
}


extension BackendController: UserBackendController {
    internal struct UserBackend {
        static let path = "users/"
    }
    
    func verifyToken() -> AnyPublisher<Bool, Error> {
        authorizedRequest(path: "auth/verify", method: "GET", modelType: SuccessResponse.self)
            .tryMap { response in
                return response.success
            }
            .eraseToAnyPublisher()
    }
    
    func getUser() -> AnyPublisher<User, Error> {
        return authorizedRequest(path: UserBackend.path + "me/", method: "GET", modelType: UserBackendModel.self)
            .tryMap { user in
                return User(name: user.name, username: user.username, followers: user.followers)
            }
            .eraseToAnyPublisher()
    }
    
    func signIn(username: String, password: String) -> AnyPublisher<String, Error> {
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
            return Empty<String, Error>(completeImmediately: true).eraseToAnyPublisher()
        }
        
        return authorizedRequest(path: UserBackend.path + "signin", method: "POST", modelType: AccessTokenModel.self, body: jsonData, contentType: .json)
            .receive(on: DispatchQueue.main)
            .tryMap { token in
                self.token = token.access_token
                return token.access_token
            }
            .eraseToAnyPublisher()        
    }
    
    func signUp(name: String, username: String, password: String) -> AnyPublisher<String, Error> {
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
            return Empty<String, Error>(completeImmediately: true).eraseToAnyPublisher()
        }
        
        return authorizedRequest(path: UserBackend.path + "signup", method: "POST", modelType: AccessTokenModel.self, body: jsonData, contentType: .json)
            .receive(on: DispatchQueue.main)
            .tryMap { token in
                self.token = token.access_token
                return token.access_token
            }
            .eraseToAnyPublisher()
    }
}
