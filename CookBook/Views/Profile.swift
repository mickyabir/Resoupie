//
//  Profile.swift
//  CookBook
//
//  Created by Michael Abir on 1/22/22.
//

import SwiftUI

struct ProfileView: View {
    @State var showNewRecipe = false
    
    var body: some View {
        NavigationView {
            Button {
                showNewRecipe = true
            } label: {
                Text("Sheet new recipe")
            }
            .sheet(isPresented: $showNewRecipe) {
                NavigationView {
                    NewRecipeView()
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}
