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
    
    @AppStorage("token") var token: String = ""
    
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
    
    static var cancellables: Set<AnyCancellable> = Set()
    
    func authorizedRequestCombine<T: Codable>(path: String, method: String, modelType: T.Type, params: [URLQueryItem]? = nil, body: Data? = nil, contentType: ContentType? = nil) -> AnyPublisher<T, ServerError> {
        var url = URLComponents(string: BackendController.url + path)!
        
        if let params = params {
            url.queryItems = params
        }

        var request = URLRequest(url: url.url!)
        request.httpMethod = method
        
        if let body = body {
            request.httpBody = body
        }
                
        if let contentType = contentType {
            request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        let bearer = "Bearer " + token
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { response -> Data in
                guard let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode == 200
                else {
                    throw ServerError.statusCode
                }
                return response.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { ServerError.map($0) }
            .eraseToAnyPublisher()
    }
    
    func authorizedRequest<T: Codable>(path: String, method: String, modelType: T.Type, params: [URLQueryItem]? = nil, body: Data? = nil, contentType: ContentType? = nil, continuation: @escaping (T?) -> Void) {
        var url = URLComponents(string: BackendController.url + path)!
        
        if let params = params {
            url.queryItems = params
        }

        var request = URLRequest(url: url.url!)
        request.httpMethod = method
        
        if let body = body {
            request.httpBody = body
        }
                
        if let contentType = contentType {
            request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        let bearer = "Bearer " + token
        request.setValue(bearer, forHTTPHeaderField: "Authorization")

        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                continuation(nil)
                return
            }
            
            var model: T?
            
            do {
                model = try JSONDecoder().decode(T.self, from: data)
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
            
            continuation(model)
        }
        task.resume()
    }
}
