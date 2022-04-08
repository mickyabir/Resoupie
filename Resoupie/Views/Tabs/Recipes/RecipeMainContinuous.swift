//
//  RecipeMainContinuous.swift
//  Resoupie
//
//  Created by Michael Abir on 2/26/22.
//

import SwiftUI

struct RecipeMainContinuousView: View {
    @ObservedObject var viewController: RecipeMainViewController
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(viewController.recipes) { recipe in
                HStack {
                    Spacer()
                    RecipeCard(recipe, width: UIScreen.main.bounds.size.width - 40)
                        .onAppear {
                            if viewController.recipes.last == recipe {
                                let _ = viewController.loadMoreRecipes()
                            }
                        }
                    Spacer()
                }
            }
        }
        .padding(.top)
        .onAppear() {
            viewController.loadRecipes()
        }
    }
}
