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

struct CustomList<ChildView: View>: View {
    @ViewBuilder var label: () -> ChildView
    var body: some View {
        VStack {
            label()
        }
    }
}

struct CustomList_Previews: PreviewProvider {
    static var previews: some View {
        CustomList() {
            Rectangle()
                .foregroundColor(Color.red)
        }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}

