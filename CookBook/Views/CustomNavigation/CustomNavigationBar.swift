//
//  CustomNavigationBar.swift
//  CookBook
//
//  Created by Michael Abir on 3/3/22.
//

import SwiftUI

struct CustomNavigationBar: View {
    @Environment(\.presentationMode) var presentation
    
    @State var titleText: String = ""
    @State var titleColor: Color = Color.theme.title

    @State var backButtonText: String = "Back"
    @State var backButtonColor: Color = Color.theme.accent

    var body: some View {
        HStack {
            backButton
            Spacer()
            
            Text(titleText)
                .foregroundColor(titleColor)
                .font(.headline)
            
            Spacer()
            backButton
                .opacity(0)
        }
        .padding()
        .background(
            Rectangle()
                .foregroundColor(Color.clear)
                .background(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.top)
                .opacity(1.0)
        )
    }
    
    private var backButton: some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(Font.title3.weight(.medium))
                .foregroundColor(backButtonColor)
            
            Text(backButtonText)
                .foregroundColor(backButtonColor)
        }
    }
}

struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomNavigationBar()
            Spacer()
        }
    }
}
