//
//  RecipeCard.swift
//  Resoupie
//
//  Created by Michael Abir on 2/2/22.
//

import SwiftUI

struct RecipeCard: View {
    @State var presentRecipe = false
    @State var image: UIImage?
    
    let width: CGFloat
    let recipeMeta: RecipeMeta
    
    init(_ recipeMeta: RecipeMeta, width: CGFloat) {
        self.recipeMeta = recipeMeta
        self.width = width
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading) {
                CustomAsyncImage(imageId: recipeMeta.recipe.image, width: width)
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(recipeMeta.recipe.name)
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        Text(recipeMeta.author)
                            .font(.subheadline)
                            .foregroundColor(Color.theme.lightText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        HStack {
                            Text(String(recipeMeta.rating))
                                .font(.subheadline)
                                .foregroundColor(Color.theme.lightText)
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.yellow)
                                .font(.system(size: 12))
                        }
                        HStack {
                            Text(String(recipeMeta.favorited))
                                .font(.subheadline)
                                .foregroundColor(Color.theme.lightText)
                            Image(systemName: "heart.fill")
                                .foregroundColor(Color.red)
                                .font(.system(size: 12))
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10)
            )
            
            NavigationLink(destination:
                            RecipeDetail(recipeMeta, backendController: BackendController()).navigationBarTitleDisplayMode(.inline), isActive: $presentRecipe) {
                EmptyView()
            }
                            
        }
        .frame(width: width, height: width + 50)
        .onTapGesture {
            presentRecipe = true
        }
        .padding(.horizontal, 5)
        .padding(.bottom)
    }
}
