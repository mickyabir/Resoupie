//
//  Profile.swift
//  CookBook
//
//  Created by Michael Abir on 1/22/22.
//

import SwiftUI

struct User {
    var name: String
}

struct Profile {
    var image: UIImage?
}


struct ProfileView: View {
    @State var presentNewRecipe = false
    @State var profile: Profile?
    @State var user: User?
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack {
                    ProgressView()
                        .opacity(profile?.image == nil ? 1.0 : 0.0)
                        .frame(width: 150, height: 150)

                    if let image = profile?.image {
                        Image(uiImage: image)
                            .frame(width: 150, height: 150)
                    }
                }
                .frame(width: 150, height: 150)
                .padding(.top)

                
                Button {
                    presentNewRecipe = true
                } label: {
                    Text("New recipe")
                }
            }
            .sheet(isPresented: $presentNewRecipe) {
                NavigationView {
                    NewRecipeView()
                }
            }
            .navigationTitle(user?.name ?? "Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Text("Test")
                    }
                }
            }
            .onAppear {
                loadProfile()
            }
        }
    }
    
    func loadProfile() {
        user = User(name: "Micky Abir")
        profile = Profile(image: nil)
    }
}
