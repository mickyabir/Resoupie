//
//  Profile.swift
//  Resoupie
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
    @Published var followers: Int = 0
    @Published var bio: String = ""
    @Published var location: String = ""

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
                self.followers = user.followers
                self.bio = user.bio
                self.location = user.location

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
        if !username.isEmpty {
            backendController.getUserRecipes(username: username)
                .eraseToAnyPublisher()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { recipes in
                    self.recipes = recipes
                })
                .store(in: &cancellables)
        }
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
    
    func updateBio() {
        backendController.updateBio(bio: bio)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { _ in
            }
            .store(in: &cancellables)
    }
    
    func updateLocation() {
        backendController.updateLocation(location: location)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { _ in
            }
            .store(in: &cancellables)
    }
}

struct ProfileOwnerView: View {
    @ObservedObject var viewController: ProfileOwnerViewController
    @State var bioEdited = false
    @State var locationEdited = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                
                ScrollView {
                    VStack {
                        if viewController.signedIn {
                            RectangleSectionInset(width: UIScreen.main.bounds.width - 40) {
                                VStack(spacing: 20) {
                                    
                                    VStack {
                                        RectangleSectionRow {
                                            ZStack(alignment: .topLeading) {
                                                TextEditor(text: $viewController.bio)
                                                    .foregroundColor(Color.theme.lightText)
                                                    .font(.body)
                                                    .onChange(of: viewController.bio) { _ in
                                                        withAnimation {
                                                            bioEdited = true
                                                        }
                                                    }

                                                if viewController.bio.isEmpty {
                                                    Text("About Me")
                                                        .foregroundColor(Color(UIColor.placeholderText))
                                                        .padding(.horizontal, 5)
                                                        .padding(.vertical, 9)
                                                        .allowsHitTesting(false)
                                                }
                                            }
                                        }
                                        
                                        HStack(spacing: 4) {
                                            VStack(spacing: 10) {
                                                Text("\(Image(systemName: "house.fill"))")
                                                    .foregroundColor(Color.theme.lightText)
                                                    .font(.body)
                                                
                                                Text("\(Image(systemName: "book.fill"))")
                                                    .foregroundColor(Color.theme.lightText)
                                                    .font(.body)
                                                
                                                Text("\(Image(systemName: "person.3.fill"))")
                                                    .foregroundColor(Color.theme.lightText)
                                                    .font(.body)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 10) {
                                                TextField("Location", text: $viewController.location)
                                                    .foregroundColor(Color.theme.lightText)
                                                    .font(.body)
                                                    .onChange(of: viewController.location) { _ in
                                                        withAnimation {
                                                            locationEdited = true
                                                        }
                                                    }
                                                
                                                Text("\(viewController.recipes.count) recipes")
                                                    .foregroundColor(Color.theme.lightText)
                                                    .font(.body)
                                                
                                                Text("\(viewController.followers) followers")
                                                    .foregroundColor(Color.theme.lightText)
                                                    .font(.body)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 10)
                                        
                                        if bioEdited || locationEdited {
                                            Divider()
                                            
                                            Button {
                                                if bioEdited {
                                                    viewController.updateBio()
                                                }
                                                
                                                if locationEdited {
                                                    viewController.updateLocation()
                                                }
                                                
                                                withAnimation {
                                                    bioEdited = false
                                                    locationEdited = false
                                                }
                                            } label: {
                                                Text("Save")
                                            }
                                            .font(.title3)
                                            .padding(.top, 5)
                                        }
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                        
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
                    EditRecipeView(isPresented: $viewController.presentNewRecipe)
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
                        .onChange(of: viewController.presentNewRecipe) { present in
                            if !present {
                                viewController.reloadProfile()
                            }
                        }
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
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            let resign = #selector(UIResponder.resignFirstResponder)
                            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewController.reloadProfile()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
