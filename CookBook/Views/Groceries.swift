//
//  Groceries.swift
//  CookBook
//
//  Created by Michael Abir on 1/19/22.
//

import SwiftUI

struct GroceriesView: View {
    var body: some View {
        Text("Groceries")
    }
}

struct Groceries_Previews: PreviewProvider {
    static var previews: some View {
        GroceriesView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
