//
//  Groceries.swift
//  CookBook
//
//  Created by Michael Abir on 1/19/22.
//

import SwiftUI

struct GroceriesView: View {
    @AppStorage("groceries") var groceries: [GroceryListItem] = []
    
    @State private var selection: UUID?
    @State private var showingDeleteAlert = false
    
    func move(from source: IndexSet, to destination: Int) {
        //        users.move(fromOffsets: source, toOffset: destination)
    }
    var body: some View {
        NavigationView{
            VStack {
                VStack(alignment: .leading) {
                    List {
                        ForEach(groceries, id: \.self) { item in
                            HStack {
                                ChecklistButton {
                                    return item.check
                                } action: {_ in
                                    if let index = groceries.firstIndex(of: item) {
                                        groceries[index].check.toggle()
                                    }
                                }
                                
                                Text(item.ingredient.name)
                            }
                        }
                        .onMove(perform: move)
                    }
                    .toolbar {
                        EditButton()
                    }
                }
                
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
