//
//  RectangleSection.swift
//  Resoupie
//
//  Created by Michael Abir on 3/22/22.
//

import SwiftUI

struct RectangleSection<Content: View>: View {
    let width: CGFloat
    
    let content: Content

    init(width: CGFloat = UIScreen.main.bounds.width - 20, @ViewBuilder content: () -> Content) {
        self.width = width
        self.content = content()
    }
    
    var body: some View {
        content
            .background(sectionRectangle)
    }
    
    private var sectionRectangle: some View {
        Rectangle()
            .foregroundColor(Color.white)
            .frame(minHeight: 50)
            .frame(width: width)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
}

struct RectangleSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white
            RectangleSection {
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
