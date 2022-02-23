//
//  CustomAsyncImage.swift
//  CookBook
//
//  Created by Michael Abir on 1/27/22.
//

import Combine
import SwiftUI

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL
    private var cancellable: AnyCancellable?

    init(url: URL) {
        self.url = url
    }

    deinit {
        cancel()
    }

    func load() {
        if let image = ImageCache.main[url] {
            self.image = image
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] in self?.cache($0) })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }
    
    private func cache(_ image: UIImage?) {
        image.map { ImageCache.main[url] = $0 }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

struct CustomAsyncImage: View {
    @StateObject private var loader: ImageLoader
    
    let imageId: String
    let width: CGFloat
    let height: CGFloat?

    init(imageId: String, width: CGFloat, height: CGFloat? = nil) {
        self.imageId = imageId
        self.width = width
        self.height = height
        let url = URL(string: BackendController.url + "images/" + imageId)!
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)
    }

    private var content: some View {
        Group {
            if loader.image != nil {
                Image(uiImage: loader.image!)
                    .resizable()
                    .frame(width: width, height: height != nil ? height! : width)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                ProgressView()
                    .frame(width: width, height: width)
            }
        }
    }}

protocol ImageCacher {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct ImageCache: ImageCacher {
    private let cache = NSCache<NSURL, UIImage>()
    
    static var main = ImageCache()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}
