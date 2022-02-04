//
//  CustomeTextField.swift
//  CookBook
//
//  Created by Michael Abir on 1/25/22.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    var text: Binding<String>
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self.text = text
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.lightGray)
                .shadow(color: Color.black.opacity(0.16), radius: 4, x: 0, y: 2)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
            
            TextField(placeholder, text: text)
                .foregroundColor(.lightText)
                .padding(.horizontal)
        }
    }
}
