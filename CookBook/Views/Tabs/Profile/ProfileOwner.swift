//
//  Profile.swift
//  CookBook
//
//  Created by Michael Abir on 1/22/22.
//

import SwiftUI
import Combine

class ProfileOwnerViewController: UserSignInViewController {
    typealias ProfileOwnerBackendController = RecipeBackendController & UserBackendController & ImageBackendController
    
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
    
    let backendController: ProfileOwnerBackendController
    
    init(_ backendController: ProfileOwnerBackendController) {
        self.backendController = backendController
        self.loadProfile()
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
            }, receiveValue: { success in
                self.reset()
                self.userAccess = false
                self.loadProfile()
            })
            .store(in: &cancellables)
    }
    
    func signUp() {
        backendController.signUp(name: self.name, username: self.username, password: self.password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { success in
                self.reset()
                self.userAccess = false
                self.loadProfile()
            })
            .store(in: &cancellables)
    }
    
    func reset() {
        name = ""
        username = ""
        password = ""
        accessState = .signIn
    }
    
    func loadProfile() {
        backendController.verifyToken()
            .receive(on: DispatchQueue.main)
            .filter { $0 == true }
            .tryMap { success in
                self.name = ""
                self.username = ""
                self.recipes = []
                self.signedIn = false

                return ()
            }
            .flatMap(backendController.getCurrentUser)
            .receive(on: DispatchQueue.main)
            .map { user in
                self.name = user.name
                self.username = user.username
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
    
    func reloadProfile() {
        backendController.getUserRecipes(username: username)
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { recipes in
                self.recipes = recipes
            })
            .store(in: &cancellables)
    }
    
    func signOut() {
        name = ""
        username = ""
        recipes = []
        signedIn = false
        
        backendController.signOut()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { success in
                print(success)
            })
            .store(in: &cancellables)
    }
}

struct ProfileOwnerView: View {
    @ObservedObject var viewController: ProfileOwnerViewController
    @ObservedObject var editRecipeViewController: EditRecipeViewController
    @State var isPresenting = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                
                ScrollView {
                    VStack {
                        ForEach(viewController.recipes) { recipeMeta in
                            RecipeCard(recipeMeta, width: UIScreen.main.bounds.width - 40)
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
                    EditRecipeView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    viewController.presentNewRecipe = false
                                } label: {
                                    Text("Cancel")
                                }
                            }
                        }

                }
            }
            .navigationTitle(viewController.name == "" ? "Profile" : viewController.name)
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
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewController.reloadProfile()
        }
    }
}