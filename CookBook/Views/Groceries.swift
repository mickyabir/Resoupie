//
//  Groceries.swift
//  CookBook
//
//  Created by Michael Abir on 1/19/22.
//

import SwiftUI

struct GroceriesView: View {
    @AppStorage("groceries") var groceries: [Ingredient] = []
    
    var body: some View {
        ScrollView {
            Text("Grocery List")
            ForEach(groceries, id: \.self) { ingredient in
                Text(ingredient.name)
            }
        }
    }
}

struct Groceries_Previews: PreviewProvider {
    static var previews: some View {
        GroceriesView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
