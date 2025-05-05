//
//  AuthViewModel.swift
//  fasting tracker test
//
//  Created by Amy  on 15/02/2025.
//


import SwiftUI
import FirebaseAuth

enum AuthError: LocalizedError {
  case mismatch(String)
  var errorDescription: String? {
    switch self {
    case .mismatch(let what): return "\(what) did not match."
    }
  }
}

class AuthModel: ObservableObject {
    //existing auth state
    @Published var isUserLoggedIn = false
    @Published var showChangeEmail = false
    @Published var showChangePassword = false
    @Published var showDeleteAccountAlert = false

    // reauth + update fields
    @Published var currentPassword = ""
    @Published var currentEmail = ""
    
    // for password flow
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var passwordError: String?
    
    // for email flow
    @Published var newEmail = ""
    @Published var confirmEmail = ""
    @Published var emailError: String?

    init() {
        // Checks if the user is logged or not
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
    
    //checking if the user exists yet
    func checkProfile(completion: @escaping (Bool)->Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            // no user = show the create profile sheet
            completion(false)
            return
        }

        FirestoreService.shared.db
        .collection("users")
        .document(uid)
        .getDocument { snap, _ in
            if let d = snap?.data(), let _ = d["username"] as? String {
            completion(true)    // profile exists
            } else {
            completion(false)   // need to create
            }
        }
    }
    
    //for password
    private func reauthenticate(password: String, completion: @escaping (Error?) -> Void) {
        guard
            let user  = Auth.auth().currentUser,
            let email = user.email
        else {
            completion(NSError(
                domain: "", code: 0,
                userInfo:[ NSLocalizedDescriptionKey: "No user logged in" ]
            ))
            return
        }
        let cred = EmailAuthProvider.credential(withEmail: email, password: password)
        user.reauthenticate(with: cred) { _, err in
              completion(err)
        }
    }
    
    //for email
    private func reauthenticate(email: String, password: String, completion: @escaping (Error?) -> Void) {
        guard
            let user  = Auth.auth().currentUser
        else {
            completion(NSError(
                domain: "", code: 0,
                userInfo:[ NSLocalizedDescriptionKey: "No user logged in" ]
            ))
            return
        }
        let cred = EmailAuthProvider.credential(withEmail: email, password: password)
        user.reauthenticate(with: cred) { _, err in
              completion(err)
        }
    }


    
    // called by “change email” button
    func changeEmailFlow() {
        emailError = nil
        currentPassword = ""
        newEmail = ""
        confirmEmail = ""
        
        showChangeEmail = true
    }

    // called by “change password” button
    func changePasswordFlow() {
        passwordError = nil
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
        
        showChangePassword = true
    }

    func deleteAccount() {
        showDeleteAccountAlert = true
    }

    // actually perform the Firebase delete (once the user confirms)
    func deleteAccountConfirmed(completion: ((Error?) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {
            completion?(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user"]))
            return
        }
        user.delete { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.isUserLoggedIn = false
                }
            }
            completion?(error)
        }
    }
    
    // helper to actually update their email
    func updateEmail(to newEmail: String, completion: @escaping (Error?) -> Void) {
        guard newEmail == confirmEmail else {
            completion(AuthError.mismatch("Email"))
            return
        }
        reauthenticate(password: currentPassword) { [weak self] err in
            if let err = err {
                completion(err); return
            }
            Auth.auth().currentUser?.updateEmail(to: self!.newEmail) { err in
                completion(err)
            }
        }
    }

    // helper to update their password
    func updatePassword(to newPassword: String, completion: @escaping (Error?) -> Void) {
        // ensure new == confirm
        guard newPassword == confirmPassword else {
            completion(AuthError.mismatch("Password"))
            return
        }
        // reauthenticate
        reauthenticate(password: currentPassword) { [weak self] err in
            if let err = err {
                completion(err); return
            }
            // update
            Auth.auth().currentUser?.updatePassword(to: self!.newPassword) { err in
                completion(err)
            }
        }
    }
}
