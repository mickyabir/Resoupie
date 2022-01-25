//
//  SearchAreaButton.swift
//  CookBook
//
//  Created by Michael Dahlin on 1/24/22.
//
import SwiftUI

struct SearchAreaButton: View {
    var body: some View {
        Button {
            print("go to edit recipie page")
        } label: {
            Label("search this area", systemImage: "location.circle")
                .frame(width: 150 , height:4, alignment: .center)
                .padding()
                .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 2)
                        )

        }
    }
}
