//
//  UserBackendController.swift
//  Resoupie
//
//  Created by Michael Abir on 2/17/22.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

struct SignInTokenModel: Codable {
    var access_token: String
    var refresh_token: String
}

struct FollowingResponse: Codable {
    var following: Bool
}

enum UserError: Error {
    case invalid
}

struct NotificationsResponse: Codable {
    var new_notifications: [String]
    var notifications: [String]
}

protocol UserBackendController {
    func verifyToken() -> AnyPublisher<Bool, Error>
    func getUser(user_id: String) -> AnyPublisher<User, Error>
    func getCurrentUser() -> AnyPublisher<User, Error>
    func signIn(username: String, password: String) -> AnyPublisher<Bool, Error>
    func signUp(name: String, username: String, password: String) -> AnyPublisher<Bool, Error>
    func signOut() -> AnyPublisher<Bool, Error>
    func checkFollowing(user_id: String) -> AnyPublisher<Bool, Error>
    func follow(user_id: String) -> AnyPublisher<Bool, Error>
    func unfollow(user_id: String) -> AnyPublisher<Bool, Error>
    func updateBio(bio: String) -> AnyPublisher<Bool, Error>
    func updateLocation(location: String) -> AnyPublisher<Bool, Error>
    func getNotifications() -> AnyPublisher<Notifications, Error>
    func readNotifications() -> AnyPublisher<Bool, Error>
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
    
    func checkFollowing(user_id: String) -> AnyPublisher<Bool, Error> {
        let params = [
            URLQueryItem(name: "follow_id", value: String(user_id)),
        ]

        return authorizedRequest(path: UserBackend.path + "following/", method: "GET", modelType: FollowingResponse.self, params: params)
            .receive(on: DispatchQueue.main)
            .tryMap { response in
                return response.following
            }
            .eraseToAnyPublisher()
    }
    
    func follow(user_id: String) -> AnyPublisher<Bool, Error> {
        let params = [
            URLQueryItem(name: "follow_id", value: String(user_id)),
        ]

        return authorizedRequest(path: UserBackend.path + "follow/", method: "POST", modelType: SuccessResponse.self, params: params)
            .receive(on: DispatchQueue.main)
            .tryMap { response in
                return response.success
            }
            .eraseToAnyPublisher()
    }
    
    func unfollow(user_id: String) -> AnyPublisher<Bool, Error> {
        let params = [
            URLQueryItem(name: "follow_id", value: String(user_id)),
        ]

        return authorizedRequest(path: UserBackend.path + "unfollow/", method: "POST", modelType: SuccessResponse.self, params: params)
            .receive(on: DispatchQueue.main)
            .tryMap { response in
                return response.success
            }
            .eraseToAnyPublisher()
    }
    
    func getUser(user_id: String) -> AnyPublisher<User, Error> {
        let params = [
            URLQueryItem(name: "user_id", value: String(user_id)),
        ]

        return authorizedRequest(path: UserBackend.path + "get/", method: "GET", modelType: User.self, params: params)
            .eraseToAnyPublisher()
    }
    
    func getCurrentUser() -> AnyPublisher<User, Error> {
        return authorizedRequest(path: UserBackend.path + "me/", method: "GET", modelType: User.self)
            .eraseToAnyPublisher()
    }
    
    func signIn(username: String, password: String) -> AnyPublisher<Bool, Error> {
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
            return Empty<Bool, Error>(completeImmediately: true).eraseToAnyPublisher()
        }
        
        return request(path: UserBackend.path + "signin/", method: "POST", modelType: SignInTokenModel.self, body: jsonData, contentType: .json)
            .receive(on: DispatchQueue.main)
            .tryMap { response in
                KeychainWrapper.main.saveAccessToken(accessToken: response.access_token)
                KeychainWrapper.main.saveRefreshToken(refreshToken: response.refresh_token)
                AppStorageContainer.main.username = username
                return true
            }
            .eraseToAnyPublisher()        
    }
    
    func signUp(name: String, username: String, password: String) -> AnyPublisher<Bool, Error> {
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
            return Empty<Bool, Error>(completeImmediately: true).eraseToAnyPublisher()
        }
        
        return request(path: UserBackend.path + "signup/", method: "POST", modelType: SignInTokenModel.self, body: jsonData, contentType: .json)
            .receive(on: DispatchQueue.main)
            .tryMap { response in
                KeychainWrapper.main.saveAccessToken(accessToken: response.access_token)
                KeychainWrapper.main.saveRefreshToken(refreshToken: response.refresh_token)
                AppStorageContainer.main.username = username
                return true
            }
            .eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Bool, Error> {
        return authorizedRequest(path: UserBackend.path + "signout/", method: "POST", modelType: SuccessResponse.self)
            .receive(on: DispatchQueue.main)
            .tryMap { response in
                KeychainWrapper.main.deleteTokens()
                AppStorageContainer.main.username = ""
                return response.success
            }
            .eraseToAnyPublisher()
    }
    
    func updateBio(bio: String) -> AnyPublisher<Bool, Error> {
        let params = [
            URLQueryItem(name: "bio", value: String(bio)),
        ]

        return authorizedRequest(path: UserBackend.path + "update/bio", method: "POST", modelType: SuccessResponse.self, params: params)
            .map { response in
                return response.success
            }
            .eraseToAnyPublisher()
    }
    
    func updateLocation(location: String) -> AnyPublisher<Bool, Error> {
        let params = [
            URLQueryItem(name: "location", value: String(location)),
        ]

        return authorizedRequest(path: UserBackend.path + "update/location", method: "POST", modelType: SuccessResponse.self, params: params)
            .map { response in
                return response.success
            }
            .eraseToAnyPublisher()
    }
    
    func getNotifications() -> AnyPublisher<Notifications, Error> {
        return authorizedRequest(path: UserBackend.path + "notifications", method: "GET", modelType: Notifications.self)
            .eraseToAnyPublisher()
    }
    
    func readNotifications() -> AnyPublisher<Bool, Error> {
        return authorizedRequest(path: UserBackend.path + "read_notifications", method: "POST", modelType: SuccessResponse.self)
            .map { response in
                return response.success
            }
            .eraseToAnyPublisher()
    }
}
