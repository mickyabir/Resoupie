//
//  RecipeMainDefault.swift
//  Resoupie
//
//  Created by Michael Abir on 2/26/22.
//

import SwiftUI

extension RecipeMainViewController {
    func getDefaultRecipes() {
        backendController.loadDefaultPageRecipes()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { recipesCategories in
                self.categoryRecipes = recipesCategories
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
            ForEach(viewController.categoryRecipes.sorted(by: { $0.key < $1.key }), id: \.key) { category in
                RecipeGroupRow(title: category.key.capitalized, recipes: category.value, backendController: viewController.backendController)
                sectionDivider
            }
        }
        .onAppear() {
            viewController.getDefaultRecipes()
        }
    }
}
