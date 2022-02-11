//
//  Groceries.swift
//  CookBook
//
//  Created by Michael Abir on 1/19/22.
//

import SwiftUI

struct GroceryListItem: Hashable, Codable, Identifiable {
    var id: String
    var ingredient: String
    var check: Bool
}

struct GroceryList: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var items: [GroceryListItem]
}

struct GroceriesView: View {
    @AppStorage("groceryLists") var groceries: [GroceryList] = []
    
    @State private var showingDeleteAlert = false
    @GestureState var isDetectingLongPress = false
    @State var showingChooseListAlert = false
    @State var showingRemoveListAlert = false
    @State var selectedRemoveListIndex: Int?

    @State var selectedItem: GroceryListItem?
    @State var selectedItemListIndex: Int?
    
    @State var selectdDeleteList: Int?
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack {
                    List {
                        ForEach(groceries) { list in
                            let listIndex = groceries.firstIndex(of: list)!
                            Section(header:
                                        HStack {
                                Image(systemName: "folder.fill.badge.minus").foregroundColor(Color.red)
                                    .onTapGesture {
                                        showingRemoveListAlert = true
                                        selectedRemoveListIndex = listIndex
                                    }
                                    .padding(.trailing)
                                    .opacity(editMode == .active ? 1.0 : 0.0)
                                    .frame(width: editMode == .active ? 30 : 0)

                                TextField("List", text: $groceries[listIndex].name).foregroundColor(Color.title)
                            }) {
                                let listIndex = groceries.firstIndex(of: list)!
                                ForEach(groceries[listIndex].items) { item in
                                    HStack {
                                        ChecklistButton {
                                            return item.check
                                        } action: {_ in
                                            if let index = groceries[listIndex].items.firstIndex(of: item) {
                                                groceries[listIndex].items[index].check.toggle()
                                                
                                                withAnimation {
                                                    let check = groceries[listIndex].items[index].check
                                                    let editedItem = groceries[listIndex].items[index]
                                                    groceries[listIndex].items.remove(at: index)
                                                    
                                                    if check {
                                                        groceries[listIndex].items.append(editedItem)
                                                    } else {
                                                        groceries[listIndex].items.insert(editedItem, at: 0)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        HStack {
                                            let itemIndex = groceries[listIndex].items.firstIndex(of: item)!
                                            
                                            TextField("Ingredient", text: $groceries[listIndex].items[itemIndex].ingredient)
                                                .font(.system(size: 16))
                                                .foregroundColor(item.check ? Color.lightText : Color.text)
                                                .opacity(item.check ? 0.8 : 1.0)
                                        }
                                        .padding(.trailing)
                                    }
                                    
                                }
                                .onDelete { offsets in
                                    groceries[listIndex].items.remove(atOffsets: offsets)
                                }
                                .onMove { sourceIndexSet, destination in
                                    groceries[listIndex].items.move(fromOffsets: sourceIndexSet, toOffset: destination)
                                }
                                .alert(isPresented: $showingRemoveListAlert) {
                                    Alert(title: Text("Delete list?"),
                                          primaryButton: .destructive(Text("Delete")) {
                                        groceries.remove(at: selectedRemoveListIndex!)
                                    },
                                          secondaryButton: .cancel()
                                    )
                                }
                                
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        let uuid = UUID().uuidString
                                        groceries[listIndex].items.append(GroceryListItem(id: uuid, ingredient: "", check: false))
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color.lightText)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .toolbar {
                        EditButton()
                    }
                }
                
                HStack {
                    Button {
                        for list in groceries {
                            let checked = list.items.filter({ $0.check })
                            if checked.count != 0 {
                                showingDeleteAlert = true
                                break
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.lightText)
                    }
                    
                    Spacer()
                    
                    Button {
                        groceries.append(GroceryList(id: UUID().uuidString, name: "", items: []))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.lightText)
                    }
                }
                .padding(.horizontal, 40)
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Delete all marked items?"),
                        primaryButton: .destructive(Text("Delete")) {
                            for index in 0..<groceries.count {
                                groceries[index].items = groceries[index].items.filter({ !$0.check })
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                .actionSheet(isPresented: $showingChooseListAlert) {
                    let buttons: [Alert.Button] = groceries.enumerated().map { i, list in
                        Alert.Button.default(Text(list.name)) {
                            let itemIndex = groceries[selectedItemListIndex!].items.firstIndex(of: selectedItem!)!
                            withAnimation {
                                groceries[selectedItemListIndex!].items.remove(at: itemIndex)
                                groceries[i].items.append(selectedItem!)
                            }
                            
                            selectedItem = nil
                            selectedItemListIndex = nil
                        }
                    }
                    return ActionSheet(title: Text("Move to list"), message: Text(""), buttons: buttons + [Alert.Button.cancel()])
                }                .padding(.bottom)
            }
            .navigationTitle("Groceries")
            .onAppear {
                if groceries.count == 0 {
                    groceries.append(GroceryList(id: UUID().uuidString, name: "Main", items: []))
                }
                
                for index in 0..<groceries.count {
                    let groceriesChecked = groceries[index].items.filter({ $0.check }).sorted(by: { $0.ingredient < $1.ingredient })
                    let groceriesNotChecked = groceries[index].items.filter({ !$0.check }).sorted(by: { $0.ingredient < $1.ingredient })
                    groceries[index].items = groceriesNotChecked + groceriesChecked
                }
            }
            .environment(\.editMode, self.$editMode)
        }
    }
}
