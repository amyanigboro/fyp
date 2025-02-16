//
//  AuthViewModel.swift
//  fasting tracker test
//
//  Created by Amy  on 15/02/2025.
//


import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isUserLoggedIn: Bool = false

    init() {
        // Check if a user is already logged in
        isUserLoggedIn = Auth.auth().currentUser != nil
    }

    func signUpUser(email: String, password: String, confirmPassword: String, completion: @escaping (String?) -> Void) {
        guard password == confirmPassword else {
            completion("Passwords do not match!")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self.isUserLoggedIn = true
                }
                completion(nil)
            }
        }
    }

    func loginUser(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self.isUserLoggedIn = true
                }
                completion(nil)
            }
        }
    }

    func logoutUser() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isUserLoggedIn = false
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func signOut() {
            do {
                try Auth.auth().signOut()
                isUserLoggedIn = false
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }

}
