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
    
    // Modify to use refresh token along with JWT
    func verifyJWT() -> Bool {
        if token == "" {
            return false
        }
        
        let jwt = token

        // get the payload part of it
        var payload64 = jwt.components(separatedBy: ".")[1]

        // need to pad the string with = to make it divisible by 4,
        // otherwise Data won't be able to decode it
        while payload64.count % 4 != 0 {
            payload64 += "="
        }

        print("base64 encoded payload: \(payload64)")
        let payloadData = Data(base64Encoded: payload64,
                               options:.ignoreUnknownCharacters)!
        let payload = String(data: payloadData, encoding: .utf8)!
        print(payload)
        
        let json = try! JSONSerialization.jsonObject(with: payloadData, options: []) as! [String:Any]
        let exp = json["expires"] as! Double
        let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
        let valid = expDate.compare(Date()) == .orderedDescending
        
        return valid
    }
    
    func authorizedRequestCombine<T: Codable>(path: String, method: String, modelType: T.Type, params: [URLQueryItem]? = nil, body: Data? = nil, contentType: ContentType? = nil) -> AnyPublisher<T, ServerError> {
        if !verifyJWT() {
            print("Refresh")
        } else {
            print("Still good")
        }
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
}
