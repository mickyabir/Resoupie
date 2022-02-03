//
//  RecipeCard.swift
//  CookBook
//
//  Created by Michael Abir on 2/2/22.
//

import SwiftUI

struct RecipeCard: View {
    var recipe: Recipe
    var width: CGFloat

    @State var presentRecipe = false
    @State var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.lightGray)
                .shadow(color: Color.black.opacity(0.12), radius: 4)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: BackendController.url + "images/" + recipe.image)) { image in
                    image
                        .resizable()
                        .frame(width: width, height: width)
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(10)
                        .clipped()
                } placeholder: {
                    Color.orange
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(recipe.name)
                            .font(.headline)
                            .foregroundColor(Color.text)
                        Text(recipe.author)
                            .font(.subheadline)
                            .foregroundColor(Color.lightText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        HStack {
                            Text(String(recipe.rating))
                                .font(.subheadline)
                                .foregroundColor(Color.lightText)
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.yellow)
                                .font(.system(size: 12))
                        }
                        HStack {
                            Text(String(recipe.favorited))
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
                RecipeDetail(recipe: recipe)
                    .navigationBarItems(leading:
                                            Button(action: {
                        presentRecipe = false
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color.orange)
                    })
            }
        })
    }
}
