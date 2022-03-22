//
//  RecipeMainDefault.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import SwiftUI

extension RecipeMainViewController {
    func getPopularRecipes() {
        backendController.loadPopularRecipes(skip: 0, limit: 10)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { recipes in
                self.popularRecipes = recipes
                self.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func getVeganRecipes() {
        backendController.loadPopularRecipes(skip: 0, limit: 10)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { recipes in
                self.categoryRecipes["vegan"] = recipes
            })
            .store(in: &cancellables)
    }
}

struct RecipeMainDefaultView: View {
    @ObservedObject var viewController: RecipeMainViewController
    
    private var sectionDivider: some View {
        Rectangle()
            .foregroundColor(Color.theme.light)
            .frame(height: 8)
            .frame(maxWidth: .infinity)
    }

    var body: some View {
        VStack {
            RecipeGroupRow(title: "Popular", recipes: viewController.popularRecipes, backendController: viewController.backendController)
                   
            sectionDivider
            
            RecipeGroupRow(title: "Vegan", recipes: viewController.categoryRecipes["vegan"] ?? [], backendController: viewController.backendController)
        }
        .onAppear() {
            viewController.getPopularRecipes()
            viewController.getVeganRecipes()
        }
    }
}
