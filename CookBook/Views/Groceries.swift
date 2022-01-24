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
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView{
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
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
                    }
                    .offset(x: 30, y: 30)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    if groceries.firstIndex(where: {$0.check}) != nil {
                        showingDeleteAlert = true
                    }
                } label: {
                    Text("Delete All Checked Items")
                }
                .offset(y: -20)
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Are you sure?"),
                        primaryButton: .destructive(Text("Delete")) {
                            groceries = groceries.filter({ !$0.check })
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .navigationTitle("Grocery List")
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
