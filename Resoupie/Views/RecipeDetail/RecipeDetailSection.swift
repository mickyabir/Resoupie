//
//  RecipeDetailSection.swift
//  Resoupie
//
//  Created by Michael Abir on 3/2/22.
//

import SwiftUI

struct RecipeDetailSection<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background(sectionRectangle)        
    }
    
    private var sectionRectangle: some View {
        Rectangle()
            .foregroundColor(Color.white)
            .frame(minHeight: 50)
            .frame(width: UIScreen.main.bounds.width - 20)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
}

struct RecipeDetailSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white
            RecipeDetailSection {
                VStack {
                    Text("Hello")
                    Text("Also hello")
                    Text("Another hello")
                    Text("Another hello")
                    Text("Another hello")
                    Text("Another hello")
                }
                .padding(.vertical)
            }
        }
    }
}
