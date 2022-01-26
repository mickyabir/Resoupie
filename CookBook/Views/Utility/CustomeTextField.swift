//
//  CustomeTextField.swift
//  CookBook
//
//  Created by Michael Abir on 1/25/22.
//

import SwiftUI

struct CustomTextField: View {
    var placholder: String
    var text: Binding<String>
    
    init(_ placholder: String, text: Binding<String>) {
        self.placholder = placholder
        self.text = text
    }
    
    var body: some View {
        TextField(placholder, text: text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .overlay(
                     RoundedRectangle(cornerRadius: 10)
                       .stroke(Color.orange, lineWidth: 2))

            .padding()
    }
}
