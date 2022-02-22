//
//  RecipesMain.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI
import Combine

struct RecipeGroupRow: View {
    var title: String
    var recipes: [RecipeMeta]
    @AppStorage("favorites") var favorites: [RecipeMeta] = []
    
    let backendController: RecipeBackendController
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundColor(Color.background)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.leading)
                .padding(.top, 10)
                .foregroundColor(Color.title2)
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack {
                    LazyHStack {
                        ForEach(recipes) { recipe in
                            ZStack(alignment: .topTrailing) {
                                RecipeCard(RecipeCardViewController(recipeMeta: recipe, width: 250, backendController: backendController))
                                
                                let favorited = (favorites.firstIndex(of: recipe) != nil)
                                Image(systemName: favorited ? "heart.fill" : "heart")
                                    .foregroundColor(favorited ? Color.red : Color.white)
                                    .font(.system(size: 18))
                                    .padding(.top, 10)
                                    .padding(.trailing, 10)
                            }
                            .padding(.top, 50)
                        }
                    }
                    .padding(.leading, 20)
                }
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 500)
    }
}

class RecipeMainViewController: ObservableObject {
    @Published var recipes: [RecipeMeta] = [RecipeMeta]()

    let backendController: RecipeBackendController
    var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    @Published var isLoading: Bool = false

    init(backendController: RecipeBackendController) {
        self.backendController = backendController
    }
    
    func loadAllRecipes() {
        isLoading = true
        
        backendController.loadAllRecipes()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { recipes in
                self.recipes = recipes
                self.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func loadRecipes() {
        isLoading = true

        backendController.loadNextRecipes(skip: 0, limit: 10)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { recipes in
                self.recipes = recipes
                self.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func loadMoreRecipes() {
        isLoading = true

        backendController.loadNextRecipes(skip: recipes.count, limit: 10)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { recipes in
                self.recipes.append(contentsOf: recipes)
                self.isLoading = false
            })
            .store(in: &cancellables)
    }
}

struct RecipeMainDefaultView: View {
    @ObservedObject var viewController: RecipeMainViewController

    var body: some View {
        LazyVStack {
            RecipeGroupRow(title: "Popular", recipes: viewController.recipes, backendController: viewController.backendController)
            
            RecipeGroupRow(title: "For You", recipes: viewController.recipes, backendController: viewController.backendController)
            
            RecipeGroupRow(title: "Vegan", recipes: viewController.recipes, backendController: viewController.backendController)
        }
        .onAppear() {
            viewController.loadAllRecipes()
        }
    }
}

struct RecipeMainContinuousView: View {
    @ObservedObject var viewController: RecipeMainViewController

    var body: some View {
        LazyVStack {
            ForEach(viewController.recipes) { recipe in
                RecipeCard(RecipeCardViewController(recipeMeta: recipe, width: UIScreen.main.bounds.size.width - 40, backendController: viewController.backendController))
                let thresholdIndex = viewController.recipes.index(viewController.recipes.endIndex, offsetBy: -1)
                if viewController.recipes.firstIndex(where: { $0.id == recipe.id }) == thresholdIndex {
                    let _ = viewController.loadMoreRecipes()
                }
            }
        }
        .onAppear() {
            viewController.loadRecipes()
        }
    }
}

struct RecipesMainView: View {
    @State var temp: String = ""
    @State var continuous: Bool = false
    @State var searchText: String = ""
    
    let viewController: RecipeMainViewController
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                Color.white
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    }
                    Spacer()
                }
                .opacity(viewController.isLoading ? 1.0 : 0.0)
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        Group {
                            if continuous {
                                RecipeMainContinuousView(viewController: viewController)
                            } else {
                                RecipeMainDefaultView(viewController: viewController)
                            }
                        }
                        .onTapGesture {
                            let resign = #selector(UIResponder.resignFirstResponder)
                            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                        }

                    }
                }
                .opacity(viewController.isLoading ? 0.0 : 1.0)
                .simultaneousGesture(
                    DragGesture().onChanged { value in
                        let resign = #selector(UIResponder.resignFirstResponder)
                        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                    }
                )
                .navigationTitle("Recipes")
                .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            continuous.toggle()
                        }
                    } label: {
                        Image(systemName: continuous ? "infinity.circle.fill" : "infinity.circle")
                            .font(.system(size: 22))
                            .foregroundColor(Color.orange)
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always)) {
                Text("Example search").searchCompletion("Example search")
            }
        }
    }
}
