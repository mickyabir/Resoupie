//
//  RecipeCard.swift
//  CookBook
//
//  Created by Michael Abir on 2/2/22.
//

import SwiftUI

class RecipeCardViewController: ObservableObject {
    var backendController: RecipeBackendController
    @Published var recipeMeta: RecipeMeta
    @Published var width: CGFloat

    init(recipeMeta: RecipeMeta, width: CGFloat, backendController: RecipeBackendController) {
        self.recipeMeta = recipeMeta
        self.width = width
        self.backendController = backendController
    }
}

struct RecipeCard: View {
    @State var presentRecipe = false
    @State var image: UIImage?
    
    @ObservedObject var viewController: RecipeCardViewController
    
    init(_ viewController: RecipeCardViewController) {
        self.viewController = viewController
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 8)
            VStack(alignment: .leading) {
                CustomAsyncImage(imageId: viewController.recipeMeta.recipe.image, width: viewController.width)
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewController.recipeMeta.recipe.name)
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        Text(viewController.recipeMeta.author)
                            .font(.subheadline)
                            .foregroundColor(Color.theme.lightText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        HStack {
                            Text(String(viewController.recipeMeta.rating))
                                .font(.subheadline)
                                .foregroundColor(Color.theme.lightText)
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.yellow)
                                .font(.system(size: 12))
                        }
                        HStack {
                            Text(String(viewController.recipeMeta.favorited))
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
            
            NavigationLink(destination:
                            NewRecipeDetail(viewController.recipeMeta, backendController: viewController.backendController as! BackendController).navigationBarTitleDisplayMode(.inline), isActive: $presentRecipe) {
                EmptyView()
            }
                            
        }
        .frame(width: viewController.width, height: viewController.width + 50)
        .onTapGesture {
            presentRecipe = true
        }
        .padding(.horizontal, 5)
//        .popover(isPresented: $presentRecipe, content: {
//                RecipeDetail(viewController: RecipeDetailViewController(recipeMeta: viewController.recipeMeta, backendController: viewController.backendController))
//                    .navigationBarItems(leading:
//                                            Button(action: {
//                        presentRecipe = false
//                    }) {
//                        Image(systemName: "chevron.down")
//                    })
//        })
        .padding(.bottom)
    }
}
