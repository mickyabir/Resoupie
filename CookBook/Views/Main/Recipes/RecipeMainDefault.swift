//
//  RecipeMainDefault.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import SwiftUI

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
