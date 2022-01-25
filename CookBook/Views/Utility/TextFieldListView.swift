//
//  TextFieldListView.swift
//  CookBook
//
//  Created by Michael Abir on 1/24/22.
//

import SwiftUI

struct TextFieldListView: View {
    @State private var steps: [String] = [""]
    
    var body: some View {
        VStack {
            ForEach(steps, id: \.self) { step in
                let index = steps.firstIndex(of: step)!
                TextField("", text: $steps[index])
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
            Button {
                steps.append(String(steps.count + 1))
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}
