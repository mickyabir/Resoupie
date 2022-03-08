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
    private var reloadImage: [URL:Bool] = [:]

    func getImagePublisher(_ url: URL) -> AnyPublisher<UIImage?, Never> {
        if let image = imageCache[url] {
            reloadImage[url] = true
            return Just(image)
                .share()
                .eraseToAnyPublisher()
        }
        
        if reloadImage[url] != true, let publisher = publishers[url] {
            return publisher
        }
        
        let publisher = load(url)
        publishers[url] = publisher
        reloadImage[url] = false
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

//fileprivate class ImageCache {
//    class Key {
//        let key: URL
//
//        init(_ key: URL) {
//            self.key = key
//        }
//    }
//    class Entry {
//        let key: URL
//        let image: UIImage
//
//        init(key: URL, image: UIImage) {
//            self.key = key
//            self.image = image
//        }
//    }
//
//    private let cache = NSCache<Key, Entry>()
//    private let delegate: ImageCacheDelegate = ImageCacheDelegate()
//
//    init() {
//        cache.delegate = delegate
//    }
//
//    subscript(_ key: URL) -> UIImage? {
//        get { cache.object(forKey: Key(key))?.image }
//        set {
//            if newValue == nil {
//                cache.removeObject(forKey: Key(key))
//            } else {
//                insert(Entry(key: key, image: newValue!))
////                cache.setObject(Entry(key: key, image: newValue!), forKey: Key(key))
//            }
//        }
//    }
//
//    func insert(_ entry: Entry) {
//        cache.setObject(entry, forKey: Key(entry.key))
//        delegate.keys.insert(entry.key)
//    }
//}
//
//fileprivate extension ImageCache {
//    final class ImageCacheDelegate: NSObject, NSCacheDelegate {
//        var keys = Set<URL>()
//
//        func cache(_ cache: NSCache<AnyObject, AnyObject>,
//                   willEvictObject object: Any) {
//            guard let entry = object as? Entry else {
//                return
//            }
//
//            keys.remove(entry.key)
//        }
//    }
//}
