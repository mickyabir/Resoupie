//
//  ImageUpload.swift
//  CookBook
//
//  Created by Michael Abir on 1/26/22.
//

import Foundation
import UIKit

struct ImageUploadResponse: Codable {
    var uuid: UUID
}

class ImageBackendController {
    private let url = BackendController.url + "images/"
    
//    func loadImageFromServer(imageId: String, continuation: @escaping (UIImage?) -> Void) {
//        URLSession.shared.dataTask(with: URL(string: url + imageId)!) { data, response, error in
//            guard let data = data, error == nil else { return }
//            print("Download Finished")
//            // always update the UI from the main thread
//            DispatchQueue.main.async() { [weak self] in
//                continuation(UIImage(data: data))
//            }
//        }.resume()
//    }
    
    
    func uploadImageToServer(image: UIImage, continuation: @escaping (UUID?) -> Void) {
        var uuid: UUID?
        
        guard let url = URL(string: url) else {
            continuation(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //create boundary
        let boundary = generateBoundary()
        //set content type
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //call createDataBody method
        let dataBody = createDataBody(media: image, boundary: boundary)
        request.httpBody = dataBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let _ = response {
            }
            if let data = data {
                do {
                    let imageUploaderResponse = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
                    uuid = imageUploaderResponse.uuid
                    continuation(uuid)
                } catch {
                    print(error)
                    continuation(nil)
                }
            }
        }.resume()
    }
    
    func createDataBody(media: UIImage?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        if let media = media {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"filename\"\(lineBreak)")
            body.append("Content-Type: image/png\(lineBreak + lineBreak)")
            body.append(media.pngData()!)
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
