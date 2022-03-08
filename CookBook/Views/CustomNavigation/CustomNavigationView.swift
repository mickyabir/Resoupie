//
//  CustomNavigationView.swift
//  CookBook
//
//  Created by Michael Abir on 3/3/22.
//

import SwiftUI

struct CustomNavigationView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                CustomNavigationBar()
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct CustomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationView {
            ScrollView {
                VStack {
                    Color.orange
                }
            }
        }
    }
}
