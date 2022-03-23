//
//  CustomList.swift
//  Resoupie
//
//  Created by Michael Abir on 2/19/22.
//

import SwiftUI

struct CustomSection<HeaderView: View, ChildView: View>: View {
    var header: HeaderView
    @ViewBuilder var content: () -> ChildView
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            header
                .foregroundColor(Color.theme.title)
                .font(.title2.weight(.semibold))
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .cornerRadius(10)
                    .foregroundColor(Color.white)
                
                VStack(alignment: .leading) {
                    content()
                        .padding(.horizontal)
                        .foregroundColor(Color.theme.text)
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

struct CustomList<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
            ScrollView {
                VStack(spacing: 20) {
                    content()
                }
            }
        }
    }
}

struct CustomList_Previews: PreviewProvider {
    static var previews: some View {
        CustomList {
            CustomSection(header: Text("Special Tools")) {
                ForEach(0..<3) { index in
                    Text(String(index))
                }
                
                Text("Test")
            }
            
            CustomSection(header: Text("Ingredients")) {
                ForEach(0..<3) { index in
                    Text(String(index))
                }
            }
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
        .previewDisplayName("iPhone 12")
    }
}

