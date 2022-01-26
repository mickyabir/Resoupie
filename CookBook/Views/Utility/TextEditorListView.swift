//
//  TextFieldListView.swift
//  CookBook
//
//  Created by Michael Abir on 1/24/22.
//

import SwiftUI

class TextEditorListViewController: ObservableObject {
    @Published var listItems: [Int] = [0]
    @Published var listItemsText: [String] = [""]
    
    func addRow() {
        listItems.append(listItems.count)
        listItemsText.append("")
    }
    
    func deleteRow(index: Int) {
        if listItems.count <= 1 {
            listItems = [0]
            listItemsText = [""]
        } else {
            listItems = Array(0...listItems.count - 2)
            listItemsText.remove(at: index)
        }
    }
}

struct TextEditorListView: View {
    @ObservedObject var viewController: TextEditorListViewController
    
    var body: some View {
        VStack {
            ForEach(viewController.listItems, id: \.self) { index in
                HStack {
                    Text("Step " + String(index + 1) + ": ")
                    TextEditor(text: $viewController.listItemsText[index])
                        .overlay(
                                 RoundedRectangle(cornerRadius: 10)
                                   .stroke(Color.orange, lineWidth: 2))
                        .frame(minHeight: 40)
                        .disableAutocorrection(true)
                    
                    Button {
                        viewController.deleteRow(index: index)
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .foregroundColor(Color.red)
                }
                .padding()
            }
            
            Button {
                viewController.addRow()
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct TextFieldListView_Previews: PreviewProvider {
    static var previews: some View {
        TextEditorListView(viewController: TextEditorListViewController())
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
