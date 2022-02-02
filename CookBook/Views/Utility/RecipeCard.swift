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
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 5)
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
                
                VStack(spacing: 2) {
                    Group {
                        Text(recipe.name)
                            .font(.headline)
                        Text(recipe.author)
                            .font(.subheadline)
                        HStack {
                            let starsBound = Int(floor(recipe.rating) - 1) > 0 ? Int(floor(recipe.rating) - 1) : 0
                            HStack(spacing: 2) {
                                ForEach(0..<starsBound) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.subheadline)
                                        .foregroundColor(Color.yellow)
                                        .font(.system(size: 14))
                                }
                                ForEach(starsBound..<5) { _ in
                                    Image(systemName: "star")
                                        .font(.subheadline)
                                        .foregroundColor(Color.yellow)
                                        .font(.system(size: 14))
                                }
                            }
                            Text("(" + String(recipe.rating) + ")")
                                .opacity(0.5)
                                .font(.system(size: 14))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
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
