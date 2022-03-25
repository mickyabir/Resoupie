//
//  ForkChildren.swift
//  Resoupie
//
//  Created by Michael Abir on 3/24/22.
//

import SwiftUI

struct ForkChildren: View {
    let children: [RecipeMeta]
    init(_ children: [RecipeMeta]) {
        self.children = children
    }
    var body: some View {
        List {
            ForEach(children) { child in
                NavigationLink(destination: RecipeDetail(child, backendController: BackendController())) {
                    HStack {
                        Text(child.recipe.name)
                            .foregroundColor(Color.theme.lightText)
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack {
                                Text("\(child.rating, specifier: "%.1f")")
                                    .foregroundColor(Color.theme.lightText)
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color.yellow)
                            }
                            
                            HStack {
                                Text("\(child.favorited)")
                                    .foregroundColor(Color.theme.lightText)
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Color.theme.red)
                            }
                        }
                        .font(.system(size: 14))
                    }
                }
            }
        }
    }
}

struct ForkChildren_Previews: PreviewProvider {
    static var previews: some View {
        ForkChildren([.empty])
    }
}
