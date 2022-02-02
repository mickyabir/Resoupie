//
//  Favorites.swift
//  CookBook
//
//  Created by Michael Abir on 1/19/22.
//

import SwiftUI

struct SortMethod {
    static func Alphabetical(lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func Popular(lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.favorited > rhs.favorited
    }
    
    static func Rating(lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.rating > rhs.rating
    }

}

struct FavoritesView: View {
    @AppStorage("favorites") var favorites: [Recipe] = []
    
    enum Sort {
        case alphabetical
        case popular
        case rating
    }
    
    var sortingMethod: [Sort: (Recipe, Recipe) -> Bool] = [
        .alphabetical: SortMethod.Alphabetical,
        .popular: SortMethod.Popular,
        .rating: SortMethod.Rating,
    ]
    
    @State var sort: Sort = .popular
    @State var displaySortOptions = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                Color.backgroundPeach
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 50) {
                        ForEach(favorites.sorted(by: sortingMethod[sort]!)) { recipe in
                            RecipeCard(recipe: recipe, width: 350)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Favorites")
            .navigationBarItems(trailing:
                                    Button(action: {
                withAnimation {
                    displaySortOptions.toggle()
                }
            }) {
                Text("Sort")
            })
        }
        .actionSheet(isPresented: $displaySortOptions) {
            ActionSheet(title: Text("Sort by"), message: Text(""), buttons: [
                .cancel(),
                .default(
                    Text("Alphabetical")
                ) {
                    withAnimation {
                        sort = .alphabetical
                    }
                },
                .default(
                    Text("Popular")
                ) {
                    withAnimation {
                        sort = .popular
                    }
                },
                .default(
                    Text("Rating")
                ) {
                    withAnimation {
                        sort = .rating
                    }
                }
            ])
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
