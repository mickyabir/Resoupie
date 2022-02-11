//
//  IngredientListEditor.swift
//  CookBook
//
//  Created by Michael Abir on 1/25/22.
//

import SwiftUI

class IngredientListEditorViewController: ObservableObject {
    @Published var listItems: [Int] = [0]
    @Published var ingredients: [String] = [""]
    @Published var quantities: [String] = [""]
    @Published var units: [String] = [""]
    var isEmpty: Bool {
        for index in listItems {
            if ingredients[index] != "" && quantities[index] != "" && units[index] != "" {
                return false
            }
        }
        
        return true
    }
    
    var ingredientsList: [Ingredient] {
        if !isEmpty {
            var list: [Ingredient] = []

            for index in listItems {
                if rowIsEmpty(index: index) {
                    continue
                }
                list.append(Ingredient(id: String(index), name: ingredients[index], quantity: quantities[index], unit: units[index]))
            }
            
            return list
        }

        return []
    }
    
    func rowIsEmpty(index: Int) -> Bool {
        if index >= listItems.count {
            return true
        }
        
        if ingredients[index] == "" || quantities[index] == "" || units[index] == "" {
            return true
        }
        
        return false
    }
    
    func addRow() {
        listItems.append(listItems.count)
        ingredients.append("")
        quantities.append("")
        units.append("")
    }
    
    func deleteRow(index: Int) {
        if listItems.count <= 1 {
            listItems = [0]
            ingredients = [""]
            quantities = [""]
            units = [""]
        } else {
            listItems = Array(0...listItems.count - 2)
            ingredients.remove(at: index)
            quantities.remove(at: index)
            units.remove(at: index)
        }
    }
}

struct IngredientListEditorView: View {
    @ObservedObject var viewController: IngredientListEditorViewController
    
    var body: some View {
        VStack {
            ForEach(viewController.listItems, id: \.self) { index in
                Divider()
                    .opacity(index > 0 ? 1 : 0)
                    .padding(.bottom)
                HStack {
                    VStack(spacing: 10) {
                        CustomTextField("Ingredient", text: $viewController.ingredients[index])
                            .disableAutocorrection(true)
                            .padding(.bottom)
                        
                        HStack {
                            CustomTextField("Quantity", text: $viewController.quantities[index])
                                .keyboardType(.decimalPad)
                            
                            CustomTextField("Unit", text: $viewController.units[index])
                                .disableAutocorrection(true)
                        }
                    }
                    .padding(.bottom)
                    
                    Button {
                        viewController.deleteRow(index: index)
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .foregroundColor(Color.red)
                    .offset(y: -6)
                }
            }
            
            Button {
                viewController.addRow()
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(Color.orange)
            }
        }
    }
}


struct IngredientListEditorView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientListEditorView(viewController: IngredientListEditorViewController())
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
