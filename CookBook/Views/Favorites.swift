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
            ZStack {
                Color.backgroundPeach
                    .ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 50) {
                        ForEach(favorites) { recipe in
                            PopularRecipeCard(recipe: recipe, width: 350)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Favorites")
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
