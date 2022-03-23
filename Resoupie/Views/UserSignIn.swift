//
//  UserSignIn.swift
//  Resoupie
//
//  Created by Michael Abir on 2/20/22.
//

import SwiftUI

enum AccessState {
    case signIn
    case signUp
}

protocol UserSignInViewController: ObservableObject {
    var name: String { get set }
    var username: String { get set }
    var password: String { get set }
    
    var presentSignIn: Bool { get set }
    
    var accessState: AccessState { get set }
    var signinError: Bool { get set }
    var signupError: Bool { get set }
    
    var emptyWarning: Bool { get set }
        
    func signIn()
    func signUp()
    
    func submit()
}

struct UserSignIn<ViewController: UserSignInViewController>: View {
    enum FocusedField: Hashable {
        case name
        case username
        case password
    }
    
    @ObservedObject var viewController: ViewController
    
    @State var emptyWarning: Bool = false
    
    @FocusState var focusedField: FocusedField?
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.black)
                .opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                Rectangle()
                    .foregroundColor(Color.theme.background)
                    .cornerRadius(10)
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation {
                                viewController.presentSignIn = false
                                focusedField = nil
                            }
                        } label: {
                            Image(systemName: "x.square.fill")
                                .foregroundColor(Color.theme.lightText)
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
                        .foregroundColor(viewController.accessState == .signIn ? Color.theme.accent : Color.theme.lightText)
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
                        .foregroundColor(viewController.accessState == .signUp ? Color.theme.accent : Color.theme.lightText)
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
                            viewController.submit()
                            focusedField = nil
                        }
                        .focused($focusedField, equals: .password)
                    
                    
                    Spacer()
                    
                    Button {
                        viewController.submit()
                        focusedField = nil
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
    
}
