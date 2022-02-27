//
//  ImageLoader.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import Combine
import UIKit

class ImageLoader: ObservableObject {
    static var main: ImageLoader = ImageLoader()
    
    private var imageCache = ImageCache()
    private var publishers: [URL:AnyPublisher<UIImage?, Never>] = [:]

    func getImagePublisher(_ url: URL) -> AnyPublisher<UIImage?, Never> {
        if let image = imageCache[url] {
            return Just(image)
                .share()
                .eraseToAnyPublisher()
        }
        
        if let publisher = publishers[url] {
            return publisher
        }
        
        let publisher = load(url)
        publishers[url] = publisher
        return publisher
    }
    
    private func load(_ url: URL) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map {
                let image = UIImage(data: $0.data)
                self.imageCache[url] = image
                return image
            }
            .replaceError(with: nil)
            .share()
            .eraseToAnyPublisher()
    }
}

fileprivate protocol ImageCacher {
    subscript(_ url: URL) -> UIImage? { get set }
}

fileprivate struct ImageCache: ImageCacher {
    private let cache = NSCache<NSURL, UIImage>()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}
