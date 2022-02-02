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
    var cornerRadius: CGFloat?
    
    var body: some View {
        AsyncImage(url: URL(string: BackendController.url + "images/" + imageId)) { image in
            image
                .resizable()
                .frame(width: width, height: height)
                .scaledToFit()
                .cornerRadius(cornerRadius ?? 0)
        } placeholder: {
            Color.white
        }
    }
}
