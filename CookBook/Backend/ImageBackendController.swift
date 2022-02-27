//
//  ImageUpload.swift
//  CookBook
//
//  Created by Michael Abir on 1/26/22.
//

import Foundation
import UIKit
import SwiftUI
import Combine

struct ImageUploadResponse: Codable {
    var image_id: String
}

protocol ImageBackendController {
    func uploadImageToServer(image: UIImage) -> AnyPublisher<String, Error>

}

extension BackendController: ImageBackendController {
    internal struct ImageBackend {
        static let path = "images/"
    }

    func uploadImageToServer(image: UIImage) -> AnyPublisher<String, Error> {
        let boundary = generateBoundary()
        let dataBody = createDataBody(media: image, boundary: boundary)
        
        return authorizedRequest(path: ImageBackend.path, method: "POST", modelType: ImageUploadResponse.self, body: dataBody, contentType: .multipart(boundary))
            .tryMap { response in
                return response.image_id
            }
            .eraseToAnyPublisher()
    }
    
    func createDataBody(media: UIImage?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        if let media = media?.cropsToSquare(maxWidth: 800) {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"filename\"\(lineBreak)")
            body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
            body.append(media.jpegImageData(maxSize: 200000, minSize: 0, times: 10)!)
            body.append(lineBreak)
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}
