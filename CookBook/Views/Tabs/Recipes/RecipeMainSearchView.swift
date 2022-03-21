//
//  RecipeMainSearchView.swift
//  CookBook
//
//  Created by Michael Abir on 3/8/22.
//

import SwiftUI

struct RecipeMainSearchView: View {
    @ObservedObject var viewController: RecipeMainViewController
    
    var body: some View {
        VStack {
            if let searchRecipes = viewController.searchRecipes {
                ForEach(searchRecipes) { recipe in
                    RecipeCard(recipe, width: UIScreen.main.bounds.size.width - 40)
                }
            }
        }
    }
}

struct RecipeMainSearchView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeMainSearchView(viewController: RecipeMainViewController(BackendController()))
    }
}
