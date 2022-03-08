//
//  RecipeMainDefault.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import SwiftUI

struct RecipeMainDefaultView: View {
    @ObservedObject var viewController: RecipeMainViewController
    
    private var sectionDivider: some View {
        Rectangle()
            .foregroundColor(Color.theme.light)
            .frame(height: 8)
            .frame(maxWidth: .infinity)
    }

    var body: some View {
        LazyVStack {
            RecipeGroupRow(title: "Popular", recipes: viewController.recipes, backendController: viewController.backendController)
                   
            sectionDivider
            
            RecipeGroupRow(title: "For You", recipes: viewController.recipes, backendController: viewController.backendController)

            sectionDivider
            
            RecipeGroupRow(title: "Vegan", recipes: viewController.recipes, backendController: viewController.backendController)
        }
        .onAppear() {
            viewController.loadAllRecipes()
        }
    }
}
