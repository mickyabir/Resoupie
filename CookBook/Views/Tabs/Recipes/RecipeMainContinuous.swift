//
//  RecipeMainContinuous.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import SwiftUI

struct RecipeMainContinuousView: View {
    @ObservedObject var viewController: RecipeMainViewController

    var body: some View {
        LazyVStack {
            ForEach(viewController.recipes) { recipe in
                RecipeCard(recipe, width: UIScreen.main.bounds.size.width - 40)
                    .onAppear {
                        if viewController.recipes.last == recipe {
                            let _ = viewController.loadMoreRecipes()
                        }
                    }
            }
        }
        .onAppear() {
            viewController.loadRecipes()
        }
    }
}
