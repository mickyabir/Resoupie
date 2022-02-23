//
//  Favorites.swift
//  CookBook
//
//  Created by Michael Abir on 1/19/22.
//

import SwiftUI
import Combine

struct SortMethod {
    static func Alphabetical(lhs: RecipeMeta, rhs: RecipeMeta) -> Bool {
        return lhs.recipe.name < rhs.recipe.name
    }
    
    static func Popular(lhs: RecipeMeta, rhs: RecipeMeta) -> Bool {
        return lhs.favorited > rhs.favorited
    }
    
    static func Rating(lhs: RecipeMeta, rhs: RecipeMeta) -> Bool {
        return lhs.rating > rhs.rating
    }

}

class FavoritesViewController: ObservableObject {
//    @AppStorage("favorites") var favorites: [RecipeMeta] = []
    @Published var favorites: [RecipeMeta]

    let backendController: RecipeBackendController
    
    private var cancellables = Set<AnyCancellable>()

    init(_ backendController: RecipeBackendController) {
        self.backendController = backendController
        self.favorites = []
    }
    
    func loadRecipes() {
        backendController.getUserFavorites()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { recipes in
                self.favorites = recipes
            })
            .store(in: &cancellables)
    }
}

struct FavoritesView: View {
    @ObservedObject var viewController: FavoritesViewController
    
    enum Sort {
        case alphabetical
        case popular
        case rating
    }
    
    var sortingMethod: [Sort: (RecipeMeta, RecipeMeta) -> Bool] = [
        .alphabetical: SortMethod.Alphabetical,
        .popular: SortMethod.Popular,
        .rating: SortMethod.Rating,
    ]
    
    @State var sort: Sort = .popular
    @State var displaySortOptions = false
        
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                Color.background
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(viewController.favorites.sorted(by: sortingMethod[sort]!)) { recipe in
                            RecipeCard(RecipeCardViewController(recipeMeta: recipe, width: UIScreen.main.bounds.width - 20, backendController: viewController.backendController))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
        .onAppear {
            viewController.loadRecipes()
        }
        .actionSheet(isPresented: $displaySortOptions) {
            ActionSheet(title: Text("Sort by"), message: Text(""), buttons: [
                .cancel(),
                .default(
                    Text("Alphabetical" + (sort == .alphabetical ? " ✓" : ""))
                ) {
                    withAnimation {
                        sort = .alphabetical
                    }
                },
                .default(
                    Text("Popular" + (sort == .popular ? " ✓" : ""))
                ) {
                    withAnimation {
                        sort = .popular
                    }
                },
                .default(
                    Text("Rating"  + (sort == .rating ? " ✓" : ""))
                ) {
                    withAnimation {
                        sort = .rating
                    }
                }
            ])
        }
    }
}
