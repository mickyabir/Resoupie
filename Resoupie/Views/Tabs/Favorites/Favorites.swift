//
//  Favorites.swift
//  Resoupie
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
    @Published var favorites: [RecipeMeta]
    @Published var displayedFavorites: [RecipeMeta]

    let backendController: RecipeBackendController
    
    private var cancellables = Set<AnyCancellable>()

    init(_ backendController: RecipeBackendController) {
        self.backendController = backendController
        self.favorites = []
        self.displayedFavorites = []
    }
    
    func loadRecipes() {
        backendController.getUserFavorites()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { recipes in
                self.favorites = recipes
                self.displayedFavorites = recipes
            })
            .store(in: &cancellables)
    }
    
    func search(_ searchText: String) {
        withAnimation {
            if searchText.isEmpty {
                self.displayedFavorites = self.favorites
            } else {
                self.displayedFavorites = self.favorites.filter( { $0.contains(searchText) } )
            }
        }
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
        
    @State var searchText: String = ""
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                Color.theme.background
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        ForEach(viewController.displayedFavorites.sorted(by: sortingMethod[sort]!)) { recipe in
                            RecipeCard(recipe, width: UIScreen.main.bounds.width - 20)
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always)) {
//            Text("Example search").searchCompletion("Example search")
        }
        .disableAutocorrection(true)
        .onChange(of: searchText) { newText in
            viewController.search(newText)
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
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
