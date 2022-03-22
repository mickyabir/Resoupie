//
//  RectangleSectionRow.swift
//  CookBook
//
//  Created by Michael Abir on 3/22/22.
//

import SwiftUI

struct RectangleSectionRow<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack {
            content()
            
            Spacer()
        }
        .padding(.top, 10)
    }
}

struct RectangleSectionRow_Previews: PreviewProvider {
    static var previews: some View {
        RectangleSectionRow {
            Text("Hello")
        }
    }
}
