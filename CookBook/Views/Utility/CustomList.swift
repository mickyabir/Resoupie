//
//  CustomList.swift
//  CookBook
//
//  Created by Michael Abir on 2/19/22.
//

import SwiftUI
//
//func contextMenu<MenuItems: View>(
//    @ViewBuilder menuItems: () -> MenuItems
//) -> some View

struct CustomSection<HeaderView: View, ChildView: View>: View {
    var header: HeaderView
    @ViewBuilder var content: () -> ChildView
    var body: some View {
        VStack(alignment: .leading) {
            header
                .foregroundColor(Color.title)
                .font(.title2.weight(.semibold))
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .cornerRadius(10)
                    .foregroundColor(Color.white)
                
                VStack(alignment: .leading) {
                    content()
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

struct CustomList<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        ScrollView {
            Color.gray
            
            VStack(spacing: 20) {
                content()
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
            }
            .background(Color.blue)
            
            CustomSection(header: Text("Special Tools")) {
                ForEach(0..<3) { index in
                    Text(String(index))
                }
            }
            .background(Color.green)

        }
        .background(Color.red)
        .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
        .previewDisplayName("iPhone 12")
    }
}

