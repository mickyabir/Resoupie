//
//  RecipeGroupRow.swift
//  Resoupie
//
//  Created by Michael Abir on 2/26/22.
//

import SwiftUI

struct RecipeGroupRow: View {
    var title: String
    var recipes: [RecipeMeta]
    @AppStorage("favorites") var favorites: [RecipeMeta] = []
    
    let backendController: RecipeBackendController
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundColor(Color.theme.background)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.leading)
                .padding(.top, 10)
                .foregroundColor(Color.theme.title2)
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(recipes) { recipe in
                        ZStack(alignment: .topTrailing) {
                            RecipeCard(recipe, width: 250)
                            
                            let favorited = (favorites.firstIndex(where: { $0.id == recipe.id }) != nil)
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
        .frame(maxWidth: .infinity, maxHeight: 500)
    }
}
