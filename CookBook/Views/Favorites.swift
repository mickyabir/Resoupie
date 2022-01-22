//
//  Favorites.swift
//  CookBook
//
//  Created by Michael Abir on 1/19/22.
//

import SwiftUI

struct FavoritesView: View {
    @AppStorage("favorites") var favorites: [Recipe] = []
    
    var body: some View {
        ScrollView {
            Text("Favorites")
            ForEach(favorites, id: \.self) { recipe in
                Text(recipe.name)
            }
        }
    }
}

struct Favorites_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
