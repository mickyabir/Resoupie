//
//  CustomAsyncImage.swift
//  CookBook
//
//  Created by Michael Abir on 1/27/22.
//

import SwiftUI

struct CustomAsyncImage: View {
    var imageId: String
    var body: some View {
        AsyncImage(url: URL(string: BackendController.url + "images/" + imageId)) { image in
            image
                .resizable()
                .frame(width: 128, height: 128)
                .scaledToFit()
                .cornerRadius(20)
        } placeholder: {
            Color.orange
        }
    }
}
