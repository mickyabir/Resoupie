//
//  SearchAreaButton.swift
//  CookBook
//
//  Created by Michael Dahlin on 1/24/22.
//
import SwiftUI

struct SearchAreaButton: View {
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Label(text, systemImage: "location.circle")
                    .frame(height:4, alignment: .center)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                    )
            }
            
        }
    }
}
