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
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        Group {
            let url = BackendController.url + "images/" + imageId
            
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .frame(width: width, height: width)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } placeholder: {
                ProgressView()
                    .frame(width: width, height: width)
            }
            
        }
    }
}
