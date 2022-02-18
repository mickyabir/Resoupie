//
//  ImageUpload.swift
//  CookBook
//
//  Created by Michael Abir on 1/26/22.
//

import Foundation
import UIKit
import SwiftUI

struct ImageUploadResponse: Codable {
    var image_id: String
}

class ImageBackendController {
    public static let url = BackendController.url + "images/"
    @AppStorage("token") var token: String = ""
    
    func uploadImageToServer(image: UIImage, continuation: @escaping (String?) -> Void) {
        let boundary = generateBoundary()
        let dataBody = createDataBody(media: image, boundary: boundary)
        
        let backendController = BackendController()
        backendController.authorizedRequest(path: "images/", method: "POST", modelType: ImageUploadResponse.self, body: dataBody, contentType: .multipart(boundary)) { response in
            continuation(response?.image_id ?? nil)
        }
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
    
    static func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        print("Download Started")
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data, error == nil else { return }
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() {
                completion(UIImage(data: data))
            }
        }).resume()
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
