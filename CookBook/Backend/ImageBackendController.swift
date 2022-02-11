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
    public static let url = BackendController.url + "images/"
    
    func uploadImageToServer(image: UIImage, continuation: @escaping (UUID?) -> Void) {
        var uuid: UUID?
        
        guard let url = URL(string: ImageBackendController.url) else {
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

extension Recipe {
    func getMainImage(completion: @escaping (UIImage?) -> Void) {
        let url = URL(string: ImageBackendController.url + self.image)!
        ImageBackendController.downloadImage(from: url) { image in
            completion(image)
        }
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
