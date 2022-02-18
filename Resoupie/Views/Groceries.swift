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
    
    @FocusState private var isTextFieldFocused: Bool
    
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
                                
                                TextField("List", text: $groceries[listIndex].name)
                                    .foregroundColor(Color.title)
                                    .disableAutocorrection(true)
                                    .onTapGesture {
                                        
                                    }
                                    .focused($isTextFieldFocused)
                            }) {
                                let listIndex = groceries.firstIndex(of: list)!
                                ForEach(groceries[listIndex].items) { item in
                                    HStack {
                                        Image(systemName: item.check ? "checkmark.circle.fill" : "circle")
                                            .frame(width: 22, height: 22)
                                            .foregroundColor(Color.orange)
                                            .font(.system(size: 22))
                                            .onTapGesture {
                                                if let index = groceries[listIndex].items.firstIndex(of: item) {
                                                    groceries[listIndex].items[index].check.toggle()
                                                    
                                                    withAnimation(Animation.easeIn(duration: 20)) {
                                                        let check = groceries[listIndex].items[index].check
                                                        let indexSet = NSMutableIndexSet(index: index)
                                                        if check {
                                                            groceries[listIndex].items.move(fromOffsets: indexSet as IndexSet, toOffset: groceries[listIndex].items.count)
                                                        } else {
                                                            groceries[listIndex].items.move(fromOffsets: indexSet as IndexSet, toOffset: 0)
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
                                                .disableAutocorrection(true)
                                                .disabled(editMode == .active)
                                                .focused($isTextFieldFocused)
                                            
                                            
                                            Image(systemName: "folder")
                                                .foregroundColor(Color.text)
                                                .opacity(editMode == .active ? 1.0 : 0.0)
                                                .onTapGesture {
                                                    selectedItem = item
                                                    selectedItemListIndex = listIndex
                                                    showingChooseListAlert = true
                                                }
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
                                
                                HStack {
                                    Spacer()
                                    
                                    Image(systemName: "plus")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.orange)
                                        .onTapGesture {
                                            groceries[listIndex].items.append(GroceryListItem(id: UUID().uuidString, ingredient: "", check: false))
                                            
                                        }
                                    
                                    Spacer()
                                }
                            }
                            .alert(isPresented: $showingRemoveListAlert) {
                                Alert(title: Text("Delete list?"),
                                      primaryButton: .destructive(Text("Delete")) {
                                    groceries.remove(at: selectedRemoveListIndex!)
                                    if groceries.count == 0 {
                                        withAnimation(.easeOut) {
                                            editMode = .inactive
                                        }
                                    }
                                },
                                      secondaryButton: .cancel()
                                )
                            }
                        }
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        for list in groceries {
                            let checked = list.items.filter({ $0.check })
                            if checked.count != 0 {
                                showingDeleteAlert = true
                                break
                            }
                        }
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color.background)
                                .cornerRadius(8)
                                .frame(width: 150, height: 40)
                            
                            Text("Clear Checked")
                        }
                        .opacity(isTextFieldFocused ? 0.0 : 1.0)
                    }
                    
                    
                    Spacer()
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
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete all checked items?"),
                    primaryButton: .destructive(Text("Delete")) {
                        for index in 0..<groceries.count {
                            groceries[index].items = groceries[index].items.filter({ !$0.check })
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationTitle("Groceries")
            .navigationBarItems(leading: EditButton())
            .navigationBarItems(trailing:
                                    Button {
                groceries.append(GroceryList(id: UUID().uuidString, name: "", items: []))
            } label: {
                Image(systemName: "folder.badge.plus")
                    .foregroundColor(Color.orange)
            })
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
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            let resign = #selector(UIResponder.resignFirstResponder)
                            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                        }
                    }
                }
            }
            .environment(\.editMode, self.$editMode)
        }
    }
}
