//
//  FrontPageView.swift
//  fasting tracker test
//
//  Created by Amy  on 12/02/2025.
//


import SwiftUI
import FirebaseAuth
import FirebaseCore

struct FrontPageView: View {
    @EnvironmentObject var authModel: AuthModel
    @StateObject private var timer = TimerModel()
    @StateObject private var nStore = NotificationStore()
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var enable2FA = false
    @State private var isLoginMode : Bool? = nil
    @State private var errorMessage: String?
    @State private var showingPasswordReset = false
    
    
    var body: some View {
        ZStack {
            if authModel.isUserLoggedIn {
                HomePageView()
                    .environmentObject(timer)
                    .environmentObject(nStore)
                    .onAppear {
                        nStore.startListening()
                    }
                    .onDisappear {
                        nStore.stopListening()
                    }
            } else {
                loginSignupUI
            }
        }
        .onChange(of: authModel.isUserLoggedIn) {
            // whenever the user changes their auth state
            if !authModel.isUserLoggedIn {
                // user logs out ---> reset local states
                isLoginMode = nil
                email = ""
                password = ""
                confirmPassword = ""
                enable2FA = false
                errorMessage = nil
                timer.reset()
            }
        }
    }
    
    var loginSignupUI: some View {
        ZStack {
            bgImage
            VStack(spacing: 40) {
                if isLoginMode == nil {
                    Spacer()
                        .frame(height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/)
                    introScreen
                }
                else {
                    Spacer()
                    if isLoginMode == true || isLoginMode == false {
                        Text(isLoginMode==true ? "Welcome back!" : "Create your account")
//                            .font(.system(size: 28, weight: .bold))
                            .font(.custom("Jua", size: 30))
                            .foregroundColor(.darkgreen)
                            .padding(.top, -10)
                    }
                    
                    loginSignupForm
                }
                Spacer()
            }
            .font(Font.custom("Jua", size: 12))
            
            
        }
    }
    
    var bgImage: some View {
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
            Image("Green Rectangle")
//                .padding(.bottom, -100.0)
                .offset(y:500)
            // Cloud Banner
            Image("BannerCloud")
                .resizable()
                .scaledToFit()
                .frame(width:600)
                .offset(y:-415)
            Image("White Rectangle")
                .offset(y:-515)
        }
    }
    
    var introScreen: some View {
        VStack {
            Text("Welcome!")
//                .font(.system(size: 48, weight: .bold))
                .font(.custom("Jua", size: 48))
                .foregroundColor(.darkgreen)
                .padding(.vertical, 20)
            VStack(spacing: 40) {
                VStack(spacing: 15){
                    Text("Would you like to start your journey?")
                        .font(.custom("Jua", size: 20))
                        .fontWeight(.regular)
                        .foregroundColor(.darkgreen)
                    Button(action: {
                        isLoginMode = false
                    }
                    ) {
                        Text("Sign Up")
                            .font(.custom("Jua", size: 24))
//                            .fontWeight(.bold)
                            .foregroundColor(.darkgreen)
                            .padding(.vertical, 10.0)
                            .padding(.horizontal, 20.0)
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                }
                VStack(spacing: 15) {
                    Text("Or are you returning?")
//                        .font(.system(size: 20, weight: .bold))
                        .font(.custom("Jua", size: 20))
                        .fontWeight(.regular)
                        .foregroundColor(.darkgreen)
                    Button(action: {
                        isLoginMode = true
                    }
                           
                    ) {
                        Text("Log In")
//                            .font(.title3)
                            .font(.custom("Jua", size: 24))
//                            .fontWeight(.bold)
                            .foregroundColor(.darkgreen)
                            .padding(.vertical, 10.0)
                            .padding(.horizontal, 20.0)
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    var loginModeToggle: some View {
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
    
    var forgotPassword: some View {
        VStack {
            if isLoginMode==true {
                Button(action: {
                    showingPasswordReset = true
                }) {
                    Text("Forgot my password")
                        .underline()
                        .font(.custom("Jua", size: 12))
                        .foregroundColor(.darkgreen)
                }
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.bottom, -30)
        .alert("Reset Password", isPresented: $showingPasswordReset) {
            TextField("Current Email", text: $email)
            Button("Cancel", role: .cancel) { }
            Button("Send") {
                authModel.resetPassword(email: email, completion: { err in
                    if let error = err {
                        print("Error: ", error)
                    }
                })
            }
            .disabled(email.isEmpty)
        } message: {
            Text("Enter your email to send a password reset link.")
        }
    }
    
    var loginSignUpButton: some View {
        Button(action: {
            if isLoginMode == true {
                authModel.loginUser(email: email, password: password) { error in
                    if let error = error {
                        errorMessage = error
                    } else {
                        authModel.isUserLoggedIn = true
                    }
                }
            } else {
                authModel.signUpUser(email: email, password: password, confirmPassword: confirmPassword) { error in
                    if let error = error {
                        errorMessage = error
                    } else {
                        authModel.isUserLoggedIn = true
                    }
                }
            }
        }) {
            Text(isLoginMode==true ? "Log in" : "Register")
                .bold()
//                .font(.system(size:20))
                .font(.custom("Jua", size: 20))
                .frame(maxWidth: 200)
                .padding()
                .background(Color.white)
                .foregroundColor(.darkgreen)
                .cornerRadius(30)
                .padding(.horizontal)
        }
    }
    
    
    var loginSignupForm: some View {
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
                
//                Toggle("Enable 2FA", isOn: $enable2FA)
//                    .toggleStyle(.switch)
//                    .padding(.horizontal)
            }
            
            //error message
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            //log in/sign up action button
            loginSignUpButton
            
            //forgot my password
            if isLoginMode==true {
                forgotPassword
            }
            
            //login mode toggle
            loginModeToggle
            
        }
        .padding(.vertical)
        .frame(width: 300.0)

    }

}
    

//struct bgImage: View {
//    var body: some View {
//        // Background Color
//        Color(.accent)
//            .ignoresSafeArea()
//        
//        Image("Shovel")
//            .resizable()
//            .scaledToFit()
//            .frame(height: 320)
//            .offset(x: 140, y: 250)
//        Image("GrassBanner")
//            .padding(.bottom, -100.0)
//            .offset(y:350)
//        Image("Green Rectangle")
//            .padding(.bottom, -100.0)
//            .offset(y:450)
//        // Cloud Banner
//        Image("BannerCloud")
//            .resizable()
//            .scaledToFit()
//            .frame(width:600)
//            .offset(y:-415)
//    }
//}
    
#Preview {
    FrontPageView().environmentObject(AuthModel())
}

