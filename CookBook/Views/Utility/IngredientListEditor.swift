//
//  IngredientListEditor.swift
//  CookBook
//
//  Created by Michael Abir on 1/25/22.
//

import SwiftUI

class IngredientListEditorViewController: ObservableObject {
    @Published var listItems: [Int] = [0]
    @Published var ingredients: [String] = ["Ingredient"]
    @Published var quantities: [String] = ["Quantity"]
    @Published var units: [String] = ["Unit"]
    
    func addRow() {
        listItems.append(listItems.count)
        ingredients.append("Ingredient")
        quantities.append("Quantity")
        units.append("Unit")
    }
    
    func deleteRow(index: Int) {
        if listItems.count <= 1 {
            listItems = [0]
            ingredients = ["Ingredient"]
            quantities = ["Quantity"]
            units = ["Unit"]
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
                HStack {
                    VStack {
                        TextEditor(text: $viewController.ingredients[index])
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange, lineWidth: 2))
                            .frame(minHeight: 40, maxHeight: 80)
                            .foregroundColor(viewController.ingredients[index] == "Ingredient" ? Color.gray : Color.black)
                            .disableAutocorrection(true)
                            .onTapGesture {
                                if viewController.ingredients[index] == "Ingredient" {
                                    viewController.ingredients[index] = ""
                                }
                            }
                            .padding(10)
                        
                        HStack {
                            TextEditor(text: $viewController.units[index])
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.orange, lineWidth: 2))
                                .frame(height: 40)
                                .foregroundColor(viewController.units[index] == "Unit" ? Color.gray : Color.black)
                                .disableAutocorrection(true)
                                .onTapGesture {
                                    if viewController.units[index] == "Unit" {
                                        viewController.units[index] = ""
                                    }
                                }
                                .padding(10)
                            
                            TextEditor(text: $viewController.quantities[index])
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.orange, lineWidth: 2))
                                .frame(height: 40)
                                .foregroundColor(viewController.quantities[index] == "Quantity" ? Color.gray : Color.black)
                            
                                .disableAutocorrection(true)
                                .onTapGesture {
                                    if viewController.quantities[index] == "Quantity" {
                                        viewController.quantities[index] = ""
                                    }
                                }
                                .padding(10)
                        }
                    }
                    .padding()
                    
                    Button {
                        viewController.deleteRow(index: index)
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .foregroundColor(Color.red)
                }
            }
            
            Button {
                viewController.addRow()
            } label: {
                Image(systemName: "plus")
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
