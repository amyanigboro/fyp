//
//  AuthView.swift
//  fasting tracker test
//
//  Created by Amy  on 12/02/2025.
//


import SwiftUI
import FirebaseAuth
import FirebaseCore

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var enable2FA = false
    @State private var isLoginMode : Bool? = nil
    @State private var errorMessage: String?
    
    
    var body: some View {
        ZStack {
            if authViewModel.isUserLoggedIn {
                HomePageView()
            } else {
                loginSignupUI
            }
        }
        .onChange(of: authViewModel.isUserLoggedIn) {
            // This runs whenever `isUserLoggedIn` changes
            if !authViewModel.isUserLoggedIn {
                // The user just logged out → reset your local states
                isLoginMode = nil
                email = ""
                password = ""
                confirmPassword = ""
                enable2FA = false
                errorMessage = nil
            }
        }
    }
    
    
    var loginSignupUI: some View {
        ZStack {
            // Background Color
            Color(.accent)
                .ignoresSafeArea()
            
            Image("Shovel")
                .resizable()
                .scaledToFit()
                .frame(height: 320)
                .offset(x: 140, y: 250)
            Image("GrassBanner")
                .padding(.bottom, -100.0)
                .offset(y:350)
            // Cloud Banner
            Image("BannerCloud")
                .resizable()
                .scaledToFit()
                .frame(width:600)
                .offset(y:-415)
            VStack(spacing: 40) {
                if isLoginMode == nil {
                    Spacer()
                        .frame(height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/)
                    Text("Welcome!")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.darkgreen)
                        .padding(.vertical, 20)
                    VStack(spacing: 40) {
                        VStack(spacing: 15){
                            Text("Would you like to start your journey?")
                                .font(.system(size: 20))
                                .fontWeight(.regular)
                                .foregroundColor(.darkgreen)
                            Button(action: {
                                isLoginMode = false
                            }
                            ) {
                                Text("Sign Up")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.darkgreen)
                                    .padding(.vertical, 10.0)
                                    .padding(.horizontal, 20.0)
                                    .background(Color.white)
                                    .cornerRadius(20)
                            }
                        }
                        VStack(spacing: 15) {
                            Text("Or are you returning?")
                                .font(.system(size: 20, weight: .bold))
                                .fontWeight(.regular)
                                .foregroundColor(.darkgreen)
                            Button(action: {
                                isLoginMode = true
                            }
                                   
                            ) {
                                Text("Log In")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.darkgreen)
                                    .padding(.vertical, 10.0)
                                    .padding(.horizontal, 20.0)
                                    .background(Color.white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    
                    
                }
                else {
                    Spacer()
                    if isLoginMode == true || isLoginMode == false {
                        Text(isLoginMode==true ? "Welcome back!" : "Create your account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.darkgreen)
                            .padding(.top, -10)
                    }
                    
                    VStack(spacing: 40) {
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        //confirm pass + 2fa
                        if isLoginMode==false {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                            
                            Toggle("Enable 2FA", isOn: $enable2FA)
                                .toggleStyle(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Toggle Style@*/DefaultToggleStyle()/*@END_MENU_TOKEN@*/)
                                .padding(.horizontal)
                        }
                        
                        //error message
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        //log in/sign up action button
                        Button(action: {
                            if isLoginMode == true {
                                authViewModel.loginUser(email: email, password: password) { error in
                                    if let error = error {
                                        errorMessage = error
                                    } else {
                                        authViewModel.isUserLoggedIn = true
                                    }
                                }
                            } else {
                                authViewModel.signUpUser(email: email, password: password, confirmPassword: confirmPassword) { error in
                                    if let error = error {
                                        errorMessage = error
                                    } else {
                                        authViewModel.isUserLoggedIn = true
                                    }
                                }
                            }
                        }) {
                            Text(isLoginMode==true ? "Log in" : "Register")
                                .bold()
                                .font(.system(size:20))
                                .frame(maxWidth: 200)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.darkgreen)
                                .cornerRadius(30)
                                .padding(.horizontal)
                        }
                        
                        //forgot my password
                        if isLoginMode==true {
                            Button(action: {
                                // Forgot password functionality (To be implemented later)
                                
                            }) {
                                Text("Forgot my password")
                                    .underline()
                                    .foregroundColor(.darkgreen)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    .cornerRadius(10)
                                    .padding(.bottom, -30)
                                
                            }
                        }
                        
                        //login mode toggle
                        Button(action: {
                            isLoginMode?.toggle()
                        }) {
                            Text(isLoginMode==true ? "Need an account? Sign up" : "Already have an account? Login")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.darkgreen)
                                .cornerRadius(20)
                        }
                        
                    }
                    .padding(.vertical)
                    .frame(width: 300.0)
                }
                
                
                
                Spacer()
                
                // Grass Banner & Shovel
                ZStack {
                }
            }
            .font(Font.custom("Sniglet-Regular", size: 12))
            
            
        }
    }
    
//    func signUpUser() {
//        guard password == confirmPassword else {
//            errorMessage = "Passwords do not match!"
//            return
//        }
//        
//        Auth.auth().createUser(withEmail: email, password: password) { result, error in
//            if let error = error {
//                errorMessage = error.localizedDescription
//            } else {
//                errorMessage = "Account created"
//            }
//        }
//    }
//    
//    func loginUser() {
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            if let error = error {
//                errorMessage = error.localizedDescription
//            } else {
//                errorMessage = "Logged in"
//            }
//        }
//    }
//    func logoutUser() {
//        Auth.auth().signOut() { result, error in
//            if let error = error {
//                errorMessage = error.localizedDescription
//            }
//            else {
//                errorMessage = "Signed out successfully"
//            }
//        }
//    }
}
    
    
#Preview {
    AuthView().environmentObject(AuthViewModel())
}

