//
//  Favorites.swift
//  CookBook
//
//  Created by Michael Abir on 1/19/22.
//

import SwiftUI

func loadFavorites() -> [Recipe] {
    if let data = UserDefaults.standard.data(forKey: "favorites") {
        if let decoded = try? JSONDecoder().decode([Recipe].self, from: data) {
            return decoded
        }
    }
    
    return []
}

struct FavoritesView: View {
    @State var favorites: [Recipe] = []
    
    var body: some View {
        ScrollView {
            Text("Favorites")
            ForEach(favorites, id: \.self) { recipe in
                Text(recipe.name)
            }
        }.onAppear {
            favorites = loadFavorites()
            print("loaded!")
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
