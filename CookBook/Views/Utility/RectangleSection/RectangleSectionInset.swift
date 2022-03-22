//
//  RectangleSectionInset.swift
//  CookBook
//
//  Created by Michael Abir on 3/22/22.
//

import SwiftUI

struct RectangleSectionInset<Content: View>: View {
    let width: CGFloat
    
    let content: Content

    init(width: CGFloat = UIScreen.main.bounds.width - 20, @ViewBuilder content: () -> Content) {
        self.width = width
        self.content = content()
    }
    var body: some View {
        RectangleSection(width: width) {
            content
                .padding(.vertical)
                .padding(.horizontal, UIScreen.main.bounds.width - width)
        }
    }
}

struct RectangleSectionInset_Previews: PreviewProvider {
    static var previews: some View {
        RectangleSectionInset {
            Text("Hello")
        }
    }
}
