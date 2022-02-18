//
//  Profile.swift
//  CookBook
//
//  Created by Michael Abir on 1/22/22.
//

import SwiftUI

struct User: RawRepresentable, Codable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(User.self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
        
    var name: String
    var username: String
    var followers: Int
}

struct Profile {
    var image: UIImage?
}

class UserAccessViewController: ObservableObject {
    @Published var userAccess: Bool = false
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @AppStorage("user") var user: User?
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
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .background(
                                Rectangle()
                                    .foregroundColor(Color.red)
                                    .opacity(emptyWarning && viewController.name.isEmpty ? 0.4 : 0.0)
                                    .cornerRadius(10)
                            )
                        
                        Spacer()
                    }
                    
                    TextField("Username", text: $viewController.username)
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .background(
                            Rectangle()
                                .foregroundColor(Color.red)
                                .opacity(emptyWarning && viewController.username.isEmpty ? 0.4 : 0.0)
                                .cornerRadius(10)
                        )


                    Spacer()
                    
                    SecureField("Password", text: $viewController.password)
                        .padding(.horizontal)
                        .autocapitalization(.none)
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
                        

                    Spacer()
                    
                    Button {
                        submitForm()
                    } label: {
                        Text("Submit")
                    }
                    .padding(.bottom)
                }
                .padding(.horizontal)
            }
            .frame(width: 300, height: 400)
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
    @State var profile: Profile?
    @AppStorage("user") var user: User?
    @AppStorage("token") var token: String?
    @ObservedObject var userAccessViewController = UserAccessViewController()
    @State var userAccess: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                
                ScrollView {
                    ZStack {
                        if let image = profile?.image {
                            Image(uiImage: image)
                                .frame(width: 150, height: 150)
                        }
                        
                        if let user = user {
                            Text(user.name)
                        } else {

                        }
                        
                        
                    }
                    .frame(width: 150, height: 150)
                    .padding(.top)
                }
                UserAccessWindow(viewController: userAccessViewController)
                    .opacity(userAccessViewController.userAccess ? 1.0 : 0.0)
            }
            .sheet(isPresented: $presentNewRecipe) {
                NavigationView {
                    NewRecipeView()
                }
            }
            .navigationTitle(user?.name ?? "Profile")
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
        }
    }
    
    func loadProfile() {
        //        user = User(name: "Micky Abir")
        //        profile = Profile(image: nil)
        let userBackendController = UserBackendController()
        userBackendController.verifyToken { success in
            if !success {
                DispatchQueue.main.async {
                    self.token = ""
                }
            }
        }
    }
}
