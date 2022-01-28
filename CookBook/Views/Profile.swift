//
//  Profile.swift
//  CookBook
//
//  Created by Michael Abir on 1/22/22.
//

import SwiftUI

class PresentNewRecipe: ObservableObject {
    @Published var showNewRecipe = false
}

struct ProfileView: View {
    @StateObject var presentNewRecipe = PresentNewRecipe()
    
    var body: some View {
        NavigationView {
            Button {
                presentNewRecipe.showNewRecipe = true
            } label: {
                Text("Sheet new recipe")
            }
            .sheet(isPresented: $presentNewRecipe.showNewRecipe) {
                NavigationView {
                    NewRecipeView()
                }
            }
            .navigationTitle("Profile")
            .environmentObject(presentNewRecipe)
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
