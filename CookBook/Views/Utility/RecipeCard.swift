//
//  RecipeCard.swift
//  CookBook
//
//  Created by Michael Abir on 2/2/22.
//

import SwiftUI

struct RecipeCard: View {
    var recipeMeta: RecipeMeta
    var width: CGFloat

    @State var presentRecipe = false
    @State var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 0)
            VStack(alignment: .leading) {
                CustomAsyncImage(imageId: recipeMeta.recipe.image, width: width)
                    .cornerRadius(10)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(recipeMeta.recipe.name)
                            .font(.headline)
                            .foregroundColor(Color.text)
                        Text(recipeMeta.recipe.author)
                            .font(.subheadline)
                            .foregroundColor(Color.lightText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        HStack {
                            Text(String(recipeMeta.rating))
                                .font(.subheadline)
                                .foregroundColor(Color.lightText)
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.yellow)
                                .font(.system(size: 12))
                        }
                        HStack {
                            Text(String(recipeMeta.favorited))
                                .font(.subheadline)
                                .foregroundColor(Color.lightText)
                            Image(systemName: "heart.fill")
                                .foregroundColor(Color.red)
                                .font(.system(size: 12))
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
            }
        }
        .frame(width: width, height: width + 50)
        .onTapGesture {
            presentRecipe = true
        }
        .padding(.horizontal, 5)
        .popover(isPresented: $presentRecipe, content: {
            NavigationView {
                RecipeDetail(recipeMeta: recipeMeta)
                    .navigationBarItems(leading:
                                            Button(action: {
                        presentRecipe = false
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color.orange)
                    })
            }
        })
        .padding(.bottom)
    }
}
