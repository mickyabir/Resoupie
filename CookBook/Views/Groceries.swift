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
                        let index = groceries.firstIndex(where: {$0.ingredient.id == item.ingredient.id})
                        if index != nil {
                            groceries.remove(at: index!)
                        }
                        
                        if item.check {
                            groceries.append(item)
                        } else {
                            groceries.insert(item, at: 0)
                        }
                    }
                    
                    Text(item.ingredient.name)
                }
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
