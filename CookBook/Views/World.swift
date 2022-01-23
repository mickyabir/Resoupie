//
//  World.swift
//  CookBook
//
//  Created by Michael Abir on 1/20/22.
//

import SwiftUI
import MapKit

struct Place: Identifiable {
    var id: UUID
    var emoji: String
    var coordinate: CLLocationCoordinate2D
}

struct PlaceAnnotationEmojiView: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.largeTitle)
    }
}

struct WorldView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 34.053578, longitude: -118.465992), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    var recipes: [Recipe]
    
    var body: some View {
        let places = recipes.filter {
            $0.coordinate != nil
        } .map {
            Place(id: $0.id, emoji: $0.emoji, coordinate: $0.coordinate!)
        }
        
        NavigationView {
            Map(coordinateRegion: $region, annotationItems: places) { place in
                MapAnnotation(coordinate: place.coordinate) {
                    NavigationLink {
                        if let index = recipes.index(where: { $0.id == place.id }) {
                            RecipeDetail(recipe: recipes[index])
                        }
                    } label: {
                        PlaceAnnotationEmojiView(title: place.emoji)
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

struct World_Previews: PreviewProvider {
    static var previews: some View {
        WorldView(recipes: [])
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
