//
//  CustomAsyncImage.swift
//  Resoupie
//
//  Created by Michael Abir on 1/27/22.
//

import Combine
import SwiftUI

class CustomAsyncImageController: ObservableObject {
    @Published var image: UIImage?
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

    func load(_ url: URL) {
        ImageLoader.main.getImagePublisher(url)
            .receive(on: DispatchQueue.main)
            .sink { image in
                self.image = image
            }
            .store(in: &cancellables)
    }
}

struct CustomAsyncImage: View {
    let imageId: String
    let width: CGFloat
    let height: CGFloat?
    let url: URL
    
    @StateObject var controller: CustomAsyncImageController
        
    init(imageId: String, width: CGFloat, height: CGFloat? = nil) {
        self.imageId = imageId
        self.width = width
        self.height = height
        _controller = StateObject(wrappedValue: CustomAsyncImageController())
        url = URL(string: BackendController.url + "images/" + imageId)!
    }
    
    var body: some View {
        content
            .onAppear {
                controller.load(url)
            }
    }
    
    private var content: some View {
        Group {
            if let image = controller.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: width, height: height != nil ? height! : width)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                ProgressView()
                    .frame(width: width, height: width)
            }
        }
    }
}
