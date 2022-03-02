//
//  Profile.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import SwiftUI
import Combine

class ProfileViewController: ObservableObject {
    typealias ProfileBackendController = RecipeBackendController
    
    @Published var recipes: [RecipeMeta] = []
    @Published var name: String
    @Published var user_id: String
    @Published var followers: Int
    
    @Published var username: String = ""
    @Published var following: Bool = false
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    let backendController: ProfileBackendController
    
    init(_ backendController: ProfileBackendController, name: String, user_id: String) {
        self.backendController = backendController
        self.name = name
        self.user_id = user_id
        self.followers = 0
        self.loadMeta()
    }
    
    func followPressed() {
        if following {
            self.unfollow()
            self.followers -= 1
        } else {
            self.follow()
            self.followers += 1
        }
    }
    
    func follow() {
        BackendController.users.follow(user_id: user_id)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { success in
                self.following = true
            }
            .store(in: &cancellables)
    }
    
    func unfollow() {
        BackendController.users.unfollow(user_id: user_id)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { success in
                self.following = false
            }
            .store(in: &cancellables)
    }
    
    func loadMeta() {
        BackendController.users.checkFollowing(user_id: user_id)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { following in
                self.following = following
            }
            .store(in: &cancellables)
        
        BackendController.users.getUser(user_id: user_id)
            .receive(on: DispatchQueue.main)
            .sink {_ in
            } receiveValue: { user in
                self.followers = user.followers
                self.username = user.username
            }
            .store(in: &cancellables)
    }
        
    func loadProfile() {
        backendController.getUserIdRecipes(user_id: user_id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { recipes in
                self.recipes = recipes
            })
            .store(in: &cancellables)
    }
}

struct ProfileView: View {
    @ObservedObject var viewController: ProfileViewController

    var body: some View {
        ZStack {
            Color.theme.background
            
            ScrollView {
                VStack {
                    ForEach(viewController.recipes) { recipeMeta in
                        RecipeCard(RecipeCardViewController(recipeMeta: recipeMeta, width: UIScreen.main.bounds.width - 40, backendController: viewController.backendController))
                    }
                }
                .padding(.top)
                .frame(maxWidth: .infinity)
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(viewController.name).font(.title3).fontWeight(.semibold).foregroundColor(Color.theme.title3)
                    Text(String(viewController.followers)).font(.subheadline).foregroundColor(Color.theme.lightText)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewController.followPressed()
                } label: {
                    Text(viewController.following ? "Following" : "Follow")
                }
                .opacity(AppStorageContainer.main.username != viewController.username ? 1.0 : 0.0)
            }
        }
        .onAppear {
            viewController.loadMeta()
            viewController.loadProfile()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
