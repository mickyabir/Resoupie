//
//  BackendController.swift
//  CookBook
//
//  Created by Michael Abir on 1/27/22.
//

import Foundation
import SwiftUI
import Combine

struct SuccessResponse: Codable {
    var success: Bool
}

struct AccessTokenModel: Codable {
    var access_token: String
}

protocol BackendControllable {
    var path: String { get }
}

enum ServerError: Error {
  case statusCode
  case decoding
  case invalidURL
  case other(Error)
  
  static func map(_ error: Error) -> ServerError {
    return (error as? ServerError) ?? .other(error)
  }
}

class BackendController {
    public static let url = "http://44.201.79.172/"
    
    public static let users: UserBackendController = BackendController()
    
    enum ContentType {
        case json
        case multipart(String)
        
        var rawValue: String {
            switch self {
            case .json:
                return "application/json"
            case .multipart(let boundary):
                return "multipart/form-data; boundary=\(boundary)"
            }
        }
    }
    
    static private var cancellables: Set<AnyCancellable> = Set()
    
    func verifyJWT(_ accessToken: String) -> Bool {
        if accessToken == "" {
            return false
        }
        
        let jwt = accessToken

        var payload64 = jwt.components(separatedBy: ".")[1]

        while payload64.count % 4 != 0 {
            payload64 += "="
        }

        let payloadData = Data(base64Encoded: payload64,
                               options:.ignoreUnknownCharacters)!
        
        let json = try! JSONSerialization.jsonObject(with: payloadData, options: []) as! [String:Any]
        let exp = json["exp"] as! Double
        let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
        let valid = expDate.compare(Date()) == .orderedDescending
        
        return valid
    }
    
    func refreshToken() -> AnyPublisher<String, Error> {
        let refreshToken = KeychainWrapper.main.getRefreshToken()
        let requestObject = AuthorizedRequestObject(accessToken: refreshToken, path: "auth/refresh", method: "POST")
        return _authorizedRequest(requestObject: requestObject)
            .decode(type: AccessTokenModel.self, decoder: JSONDecoder())
            .tryMap { response in
                KeychainWrapper.main.saveAccessToken(accessToken: response.access_token)
                return response.access_token
            }
            .eraseToAnyPublisher()
    }
    
    struct RequestObject {
        var path: String
        var method: String
        var params: [URLQueryItem]? = nil
        var body: Data? = nil
        var contentType: ContentType? = nil
    }
    
    struct AuthorizedRequestObject {
        var accessToken: String
        var path: String
        var method: String
        var params: [URLQueryItem]? = nil
        var body: Data? = nil
        var contentType: ContentType? = nil
    }
    
    func request<T: Codable>(path: String, method: String, modelType: T.Type, params: [URLQueryItem]? = nil, body: Data? = nil, contentType: ContentType? = nil) -> AnyPublisher<T, Error> {
        
        let requestObject = RequestObject(path: path, method: method, params: params, body: body, contentType: contentType)
        
        return _request(requestObject: requestObject)
            .decode(type: modelType, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
        
    func _request(requestObject: RequestObject) -> AnyPublisher<Data, Error> {
        var url = URLComponents(string: BackendController.url + requestObject.path)!
        
        if let params = requestObject.params {
            url.queryItems = params
        }
        
        var request = URLRequest(url: url.url!)
        request.httpMethod = requestObject.method
        
        if let body = requestObject.body {
            request.httpBody = body
        }
        
        if let contentType = requestObject.contentType {
            request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { response -> Data in
                guard let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode == 200
                else {
                    throw ServerError.statusCode
                }
                return response.data
            }
            .mapError { ServerError.map($0) }
            .eraseToAnyPublisher()
    }

    
    func authorizedRequest<T: Codable>(path: String, method: String, modelType: T.Type, params: [URLQueryItem]? = nil, body: Data? = nil, contentType: ContentType? = nil) -> AnyPublisher<T, Error> {
        let accessToken = KeychainWrapper.main.getAccessToken()
        var requestObject = AuthorizedRequestObject(accessToken: accessToken, path: path, method: method, params: params, body: body, contentType: contentType)

        
        if !verifyJWT(accessToken) {
            return refreshToken()
                .map { newToken in
                    requestObject.accessToken = newToken
                    return requestObject
                }
                .flatMap(self._authorizedRequest)
                .decode(type: modelType, decoder: JSONDecoder())
                .eraseToAnyPublisher()
        }
        
        return _authorizedRequest(requestObject: requestObject)
            .decode(type: modelType, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func _authorizedRequest(requestObject: AuthorizedRequestObject) -> AnyPublisher<Data, Error> {
        var url = URLComponents(string: BackendController.url + requestObject.path)!
        
        if let params = requestObject.params {
            url.queryItems = params
        }

        var request = URLRequest(url: url.url!)
        request.httpMethod = requestObject.method
        
        if let body = requestObject.body {
            request.httpBody = body
        }
                
        if let contentType = requestObject.contentType {
            request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        let bearer = "Bearer " + requestObject.accessToken
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { response -> Data in
                guard let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode == 200
                else {
                    throw ServerError.statusCode
                }
                return response.data
            }
            .mapError { ServerError.map($0) }
            .eraseToAnyPublisher()
    }
}
