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
    func uploadImageToServerCombine(image: UIImage) -> AnyPublisher<String, Error>

}

extension BackendController: ImageBackendController {
    internal struct ImageBackend {
        static let path = "images/"
    }

    func uploadImageToServerCombine(image: UIImage) -> AnyPublisher<String, Error> {
        let boundary = generateBoundary()
        let dataBody = createDataBody(media: image, boundary: boundary)
        
        return authorizedRequestCombine(path: ImageBackend.path, method: "POST", modelType: ImageUploadResponse.self, body: dataBody, contentType: .multipart(boundary))
            .tryMap { response in
                return response.image_id
            }
            .eraseToAnyPublisher()
    }
    
    func createDataBody(media: UIImage?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        if let media = media?.cropsToSquare() {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"filename\"\(lineBreak)")
            body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
            body.append(media.jpegImageData(maxSize: 4000000, minSize: 0, times: 10)!)
            body.append(lineBreak)
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
            print("data======>>>",data)
        }
    }
}

extension UIImage {
    func jpegImageData(maxSize: Int, minSize: Int, times: Int) -> Data? {
        var maxQuality: CGFloat = 1.0
        var minQuality: CGFloat = 0.0
        var bestData: Data?
        for _ in 1...times {
            let thisQuality = (maxQuality + minQuality) / 2
            guard let data = self.jpegData(compressionQuality: thisQuality) else { return nil }
            let thisSize = data.count
            if thisSize > maxSize {
                maxQuality = thisQuality
            } else {
                minQuality = thisQuality
                bestData = data
                if thisSize > minSize {
                    return bestData
                }
            }
        }

        return bestData
    }

    func cropsToSquare() -> UIImage {
        let refWidth = CGFloat((self.cgImage!.width))
        let refHeight = CGFloat((self.cgImage!.height))
        let cropSize = refWidth > refHeight ? refHeight : refWidth
        
        let x = (refWidth - cropSize) / 2.0
        let y = (refHeight - cropSize) / 2.0
        
        let cropRect = CGRect(x: x, y: y, width: cropSize, height: cropSize)
        let imageRef = self.cgImage?.cropping(to: cropRect)
        let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)
        
        return cropped
    }
}
