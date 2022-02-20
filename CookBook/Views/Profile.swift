//
//  Profile.swift
//  CookBook
//
//  Created by Michael Abir on 1/22/22.
//

import SwiftUI

struct User {
    var name: String
    var username: String
    var followers: Int
}

class UserAccessViewController: ObservableObject {
    @Published var userAccess: Bool = false
    @Published var submitted: Bool = false
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    
    @AppStorage("username") var stored_username: String?
    @AppStorage("name") var stored_name: String?
    
    @AppStorage("token") var token: String?
    let backendController = UserBackendController()
    enum AccessState {
        case signIn
        case signUp
    }
    
    @Published var accessState: AccessState = .signIn
    @Published var signinError: Bool = false
    @Published var signupError: Bool = false
    
    func signIn() {
        backendController.signIn(username: self.username, password: self.password) { token in
            if let token = token {
                DispatchQueue.main.async {
                    withAnimation {
                        self.token = token
                        self.reset()
                        self.userAccess = false
                        self.submitted = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.signinError = true
                }
            }
        }
    }
    
    func signUp() {
        backendController.signUp(name: self.name, username: self.username, password: self.password) { token in
            if let token = token {
                DispatchQueue.main.async {
                    withAnimation {
                        self.token = token
                        self.reset()
                        self.userAccess = false
                        self.submitted = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.signupError = true
                }
            }
        }
    }
    
    func reset() {
        name = ""
        username = ""
        password = ""
        accessState = .signIn
    }
}

struct UserAccessWindow: View {
    @ObservedObject var viewController: UserAccessViewController
    
    @State var emptyWarning: Bool = false
    
    enum FocusedField: Hashable {
        case name
        case username
        case password
    }
    
    @FocusState var focusedField: FocusedField?
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.black)
                .opacity(0.3)
            
            ZStack {
                Rectangle()
                    .foregroundColor(Color.background)
                    .cornerRadius(10)
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation {
                                viewController.userAccess = false
                                focusedField = nil
                            }
                        } label: {
                            Image(systemName: "x.square.fill")
                                .foregroundColor(Color.lightText)
                                .font(.system(size: 20))
                        }
                        .padding([.trailing, .top])
                    }
                    Spacer()
                }
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation {
                                viewController.accessState = .signIn
                            }
                        } label: {
                            Text("Sign In")
                        }
                        .foregroundColor(viewController.accessState == .signIn ? Color.orange : Color.lightText)
                        .opacity(viewController.accessState == .signIn ? 1.0 : 0.7)
                        .alert(isPresented: $viewController.signinError) {
                            Alert(title: Text("Error"), message: Text("Can't Sign In"), dismissButton: .none)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                viewController.accessState = .signUp
                            }
                        } label: {
                            Text("Sign Up")
                        }
                        .foregroundColor(viewController.accessState == .signUp ? Color.orange : Color.lightText)
                        .opacity(viewController.accessState == .signUp ? 1.0 : 0.7)
                        
                        Spacer()
                    }
                    .padding(.top)
                    
                    Spacer()
                    
                    if viewController.accessState == .signUp {
                        TextField("Name", text: $viewController.name)
                            .padding(.horizontal)
                            .submitLabel(.next)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .background(
                                Rectangle()
                                    .foregroundColor(Color.red)
                                    .opacity(emptyWarning && viewController.name.isEmpty ? 0.4 : 0.0)
                                    .cornerRadius(10)
                            )
                            .focused($focusedField, equals: .name)
                            .onSubmit {
                                focusedField = .username
                            }
                        
                        Spacer()
                    }
                    
                    TextField("Username", text: $viewController.username)
                        .padding(.horizontal)
                        .submitLabel(.next)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .background(
                            Rectangle()
                                .foregroundColor(Color.red)
                                .opacity(emptyWarning && viewController.username.isEmpty ? 0.4 : 0.0)
                                .cornerRadius(10)
                        )
                        .focused($focusedField, equals: .username)
                        .onSubmit {
                            focusedField = .password
                        }
                    
                    Spacer()
                    
                    SecureField("Password", text: $viewController.password)
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .submitLabel(.go)
                        .disableAutocorrection(true)
                        .background(
                            Rectangle()
                                .foregroundColor(Color.red)
                                .opacity(emptyWarning && viewController.password.isEmpty ? 0.4 : 0.0)
                                .cornerRadius(10)
                        )
                        .onSubmit {
                            submitForm()
                        }
                        .focused($focusedField, equals: .password)
                    
                    
                    Spacer()
                    
                    Button {
                        submitForm()
                    } label: {
                        Text("Submit")
                    }
                    .padding(.bottom)
                }
                .padding(.horizontal)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button("Done") {
                                focusedField = nil
                            }
                        }
                    }
                }                
            }
            .frame(width: 300, height: 300)
        }
    }
    
    func submitForm() {
        if viewController.username == "" || viewController.password == "" {
            withAnimation {
                emptyWarning = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation {
                    emptyWarning = false
                }
            }
        } else if viewController.accessState == .signUp && viewController.name == "" {
            withAnimation {
                emptyWarning = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation {
                    emptyWarning = false
                }
            }
        } else {
            focusedField = nil
            
            if viewController.accessState == .signIn {
                viewController.signIn()
            } else if viewController.accessState == .signUp {
                viewController.signUp()
            }
        }
    }
}

struct ProfileView: View {
    @State var presentNewRecipe = false
    
    @AppStorage("username") var stored_username: String = ""
    @AppStorage("name") var stored_name: String = ""
    
    @AppStorage("token") var token: String = ""
    @ObservedObject var userAccessViewController = UserAccessViewController()
    
    @State var recipes: [RecipeMeta]?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                
                ScrollView {
                    VStack {
                        if let recipes = recipes {
                            
                            ForEach(recipes) { recipeMeta in
                                RecipeCard(recipeMeta: recipeMeta, width: UIScreen.main.bounds.width - 40)
                            }
                        }
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                }
                
                UserAccessWindow(viewController: userAccessViewController)
                    .opacity(userAccessViewController.userAccess ? 1.0 : 0.0)
            }
            .sheet(isPresented: $presentNewRecipe) {
                NavigationView {
                    NewRecipeView()
                }
            }
            .navigationTitle(stored_name == "" ? "Profile" : stored_name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ZStack {
                        Button {
                            withAnimation {
                                userAccessViewController.userAccess = true
                            }
                        } label: {
                            Text("Sign In")
                        }
                        .opacity(token == "" ? 1.0 : 0.0)
                        
                        Button {
                            presentNewRecipe = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .opacity(token != "" ? 1.0 : 0.0)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            token = ""
                            stored_name = ""
                            stored_username = ""
                            recipes = nil
                        }
                    } label: {
                        Text("Sign Out")
                    }
                    .opacity(token != "" ? 1.0 : 0.0)
                }
            }
            .onAppear {
                loadProfile()
            }
            .onChange(of: userAccessViewController.submitted) { submitted in
                if submitted == true {
                    loadProfile()
                    userAccessViewController.submitted = false
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func loadProfile() {
        let userBackendController = UserBackendController()
        userBackendController.verifyToken { success in
            if !success {
                DispatchQueue.main.async {
                    self.token = ""
                    self.stored_name = ""
                    self.stored_username = ""
                    self.recipes = []
                }
            }
        }
        userBackendController.getUser { user in
            if let user = user {
                DispatchQueue.main.async {
                    self.stored_name = user.name
                    self.stored_username = user.username
                    
                    let recipeBackendController = RecipeBackendController()
                    recipeBackendController.getUserRecipes(username: self.stored_username) { recipes in
                        DispatchQueue.main.async {
                            self.recipes = recipes
                        }
                    }
                }
            }
        }
    }
}
