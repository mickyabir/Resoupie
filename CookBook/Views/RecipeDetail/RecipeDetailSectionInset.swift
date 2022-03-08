//
//  RecipeDetailSectionInset.swift
//  CookBook
//
//  Created by Michael Abir on 3/4/22.
//

import SwiftUI

struct RecipeDetailSectionInset<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        RecipeDetailSection {
            content()
                .padding(.vertical)
                .padding(.horizontal, 30)
        }
    }
}

struct RecipeDetailSectionInset_Previews: PreviewProvider {
    static var previews: some View {
        let specialTools = ["Whisk", "Instant Pot", "Blender"]
        
        RecipeDetailSectionInset {
            VStack {
                HStack {
                    Text("Special Tools")
                        .foregroundColor(Color.theme.title3)
                        .font(.title3)
                    Spacer()
                }
                
                Divider()
                    .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading) {
                        ForEach (specialTools, id: \.self) { tool in
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundColor(Color.theme.accent)
                                    .font(.system(size: 24))
                                
                                Text(tool)
                                    .foregroundColor(Color.theme.text)
                                    .padding(.vertical, 5)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
}
