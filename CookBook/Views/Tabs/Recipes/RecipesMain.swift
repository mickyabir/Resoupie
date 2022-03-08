//
//  RecipesMain.swift
//  CookBook
//
//  Created by Michael Abir on 1/18/22.
//

import SwiftUI
import Combine

class RecipeMainViewController: ObservableObject {
    @Published var recipes: [RecipeMeta] = [RecipeMeta]()

    let backendController: RecipeBackendController
    var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    @Published var isLoading: Bool = false

    init(_ backendController: RecipeBackendController) {
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
                for recipe in recipes {
                    if !self.recipes.contains(recipe) {
                        self.recipes.append(recipe)
                    }
                }
                self.isLoading = false
            })
            .store(in: &cancellables)
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
                Color.theme.background
                
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
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always)) {
                Text("Example search").searchCompletion("Example search")
            }
        }
    }
}
