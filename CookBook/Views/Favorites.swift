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
        NavigationView {
            ScrollView {
                Text("Favorites")
                ForEach(favorites, id: \.self) { recipe in
                    NavigationLink {
                        RecipeDetail(recipe: recipe)
                    } label: {
                        Text(recipe.name)
                    }
                    Spacer()
                }
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
