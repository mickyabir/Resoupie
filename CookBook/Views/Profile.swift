//
//  Profile.swift
//  CookBook
//
//  Created by Michael Abir on 1/22/22.
//

import SwiftUI
import Combine

struct User {
    var name: String
    var username: String
    var followers: Int
}

class ProfileViewController: UserSignInViewController {
    typealias ProfileBackendController = RecipeBackendController & UserBackendController & ImageBackendController

    @AppStorage("token") var token: String = ""
    @AppStorage("username") var stored_username: String = ""
    @AppStorage("name") var stored_name: String = ""

    @Published var emptyWarning: Bool = false
    @Published var recipes: [RecipeMeta] = []
    @Published var signedIn: Bool = false
    @Published var userAccess: Bool = false
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var accessState: AccessState = .signIn
    @Published var signinError: Bool = false
    @Published var signupError: Bool = false
    @Published var presentNewRecipe = false
    @Published var presentSignIn: Bool = false
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    let backendController: ProfileBackendController
    
    init(backendController: ProfileBackendController) {
        self.backendController = backendController
        self.reloadProfile()
    }
    
    func submit() {
        if username == "" || password == "" {
            withAnimation {
                emptyWarning = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation {
                    self.emptyWarning = false
                }
            }
        } else if accessState == .signUp && name == "" {
            withAnimation {
                self.emptyWarning = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation {
                    self.emptyWarning = false
                }
            }
        } else {
            if accessState == .signIn {
                signIn()
            } else if accessState == .signUp {
                signUp()
            }
        }
        
    }
    
    func signIn() {
        backendController.signIn(username: self.username, password: self.password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { token in
                self.token = token
                self.reset()
                self.userAccess = false
                self.reloadProfile()
            })
            .store(in: &cancellables)
    }
    
    func signUp() {
        backendController.signUp(name: self.name, username: self.username, password: self.password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { token in
                self.token = token
                self.reset()
                self.userAccess = false
                self.reloadProfile()
            })
            .store(in: &cancellables)
    }
    
    func reset() {
        name = ""
        username = ""
        password = ""
        accessState = .signIn
    }
    
    func reloadProfile() {
        backendController.verifyToken()
            .receive(on: DispatchQueue.main)
            .filter { $0 == true }
            .tryMap { success in
                self.token = ""
                self.stored_name = ""
                self.stored_username = ""
                self.recipes = []
                self.signedIn = false

                return ()
            }
            .flatMap(backendController.getUser)
            .receive(on: DispatchQueue.main)
            .map { user in
                self.stored_name = user.name
                self.stored_username = user.username
                self.signedIn = true
                
                return user.username
            }
            .flatMap(backendController.getUserRecipes)
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { recipes in
                self.recipes = recipes
            })
            .store(in: &cancellables)
    }
    
    func loadProfile() {
        if recipes == [] {
            reloadProfile()
        }
    }
    
    func signOut() {
        token = ""
        stored_name = ""
        stored_username = ""
        recipes = []
        signedIn = false
    }
}

struct ProfileView: View {
    @ObservedObject var viewController: ProfileViewController
    @State var isPresenting = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                
                ScrollView {
                    VStack {
                        ForEach(viewController.recipes) { recipeMeta in
                            RecipeCard(RecipeCardViewController(recipeMeta: recipeMeta, width: UIScreen.main.bounds.width - 40, backendController: viewController.backendController))
                        }
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                }
                
                UserSignIn(viewController: viewController)
                    .opacity(viewController.userAccess ? 1.0 : 0.0)
            }
            .sheet(isPresented: $viewController.presentNewRecipe) {
                NavigationView {
                    NewRecipeView(viewController: NewRecipeViewController(viewController.backendController))
                }
            }
            .navigationTitle(viewController.stored_name == "" ? "Profile" : viewController.stored_name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ZStack {
                        Button {
                            withAnimation {
                                viewController.userAccess = true
                            }
                        } label: {
                            Text("Sign In")
                        }
                        .opacity(!viewController.signedIn ? 1.0 : 0.0)
                        
                        Button {
                            viewController.presentNewRecipe = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .opacity(viewController.signedIn ? 1.0 : 0.0)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            viewController.signOut()
                        }
                    } label: {
                        Text("Sign Out")
                    }
                    .opacity(viewController.signedIn ? 1.0 : 0.0)
                }
            }
            .onAppear {
                viewController.loadProfile()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
