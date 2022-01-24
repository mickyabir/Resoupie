//
//  Groceries.swift
//  CookBook
//
//  Created by Michael Abir on 1/19/22.
//

import SwiftUI

struct ChecklistButton: View {
    @State private var didTap: Bool = false
    var initialize: () -> Bool
    var action: (_: Bool) -> Void
    
    var body: some View {
        Button {
            self.didTap = !self.didTap
            action(didTap)
        } label: {
            Image(systemName: didTap ? "checkmark.circle.fill" : "circle")
                .frame(width: 18, height: 18)
                .clipShape(Circle())
        }.onAppear {
            didTap = initialize()
        }
    }
}

struct GroceriesView: View {
    @AppStorage("groceries") var groceries: [GroceryListItem] = []
    
    @State private var selection: UUID?
    
    var body: some View {
        ScrollView {
            Text("Grocery List")
            ForEach(groceries, id: \.self) { item in
                HStack {
                    ChecklistButton {
                        return item.check
                    } action: {_ in
                        if let index = groceries.firstIndex(of: item) {
                            groceries[index].check = !groceries[index].check
                        }
                    }
                    
                    Text(item.ingredient.name)
                }
            }
            
            Button {
                groceries = groceries.filter({ !$0.check })
            } label: {
                Text("Delete All Checked Items")
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
