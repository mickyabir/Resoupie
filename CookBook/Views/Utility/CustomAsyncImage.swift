//
//  CustomAsyncImage.swift
//  CookBook
//
//  Created by Michael Abir on 1/27/22.
//

import SwiftUI

struct CustomAsyncImage: View {
    var imageId: String
    var width: CGFloat
    var height: CGFloat?
    
    var body: some View {
        let url = BackendController.url + "images/" + imageId
        if let cached = ImageCache[url] {
            cached
                .resizable()
                .frame(width: width, height: width)
                .aspectRatio(contentMode: .fill)
                .clipped()
        } else {
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .frame(width: width, height: width)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                let _ = (ImageCache[url] = image)
            } placeholder: {
                Color.orange
            }
        }
    }
}

fileprivate class ImageCache {
    static private var cache: [String: Image] = [:]
    static subscript(url: String) -> Image? {
        get{
            ImageCache.cache[url]
        }
        set{
            ImageCache.cache[url] = newValue
        }
    }
}
