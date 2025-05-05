//
//  ProfileView.swift
//  FastHabbit
//
//  Created by Amy  on 23/04/2025.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import SwiftUIIntrospect

struct ProfileView: View {
    @EnvironmentObject var authModel: AuthModel
    @State private var showingUsernamePrompt = false
    @State private var showingEmailPrompt = false
    @State private var showingPasswordPrompt = false
    @State private var newUsername = ""
    @State private var newEmail    = ""
    @State private var newPassword = ""
    @State private var profile: UserProfile?  // define a simple UserProfile struct
    @State private var showingFriendsList = false

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    @State private var copied = false

    var body: some View {
//        List {
        VStack(alignment: .leading) {
//            Section {
            Spacer()
            HStack {
                // tap to pick new photo
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if //shows users current photo
                    let urlString = profile?.profileImageURL,
                    !urlString.isEmpty,
                    let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                                case .success(let img):
                                    img
                                      .resizable()
                                      .scaledToFill()
                                case .failure: //loading failed
                                    Circle().fill(Color.gray)
                                default: // still loading
                                    ProgressView()
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())

                    //if doesnt exist, show a placeholder
                    } else {
                        Circle()
                        .fill(Color.gray)
                        .frame(width: 80, height: 80)
                    }
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        guard
                            let data = try? await newItem?.loadTransferable(type: Data.self),
                            let _ = UIImage(data: data)
                        else { return }
                        loadProfile()
                        // 3a) upload to Storage
                        let uid = Auth.auth().currentUser!.uid
                        StorageService.shared.uploadProfileImage(data, for: uid) { result in
                            switch result {
                            case .success(let url):
                                print("✅ Storage upload succeeded, downloadURL:", url)
                                FirestoreService.shared.updateProfileImageURL(url.absoluteString) { err in
                                    if let err = err {
                                        print("🔥 failed to write URL to Firestore:", err)
                                    } else {
                                        print("✅ profileImageURL field updated in Firestore")
                                    }
                                }
                            case .failure(let err):
                                print("🔥 Storage upload failed:", err)
                            }
                        }
                    }
                }
                
                VStack(alignment:.leading) {
                    Text(profile?.username ?? "")
                        .font(.title3)
                    Text(profile?.email ?? "")
                        .font(.caption)
                    Text(profile?.uid ?? "")
                        .font(.caption)
                }
            }
            .padding()
            .frame(maxWidth:.infinity)
            .background(Color.white.opacity(0.9))
            .cornerRadius(30)
            .foregroundStyle(.darkgreen)
            .bold()
            HStack{
                Text("Copy UID")
                Image(systemName: "document.on.document")
            }
            .foregroundColor(.darkgreen)
            .padding(10)
            .background(Color.white)
            .cornerRadius(15)
            .onTapGesture {
                UIPasteboard.general.string = profile?.uid
                copied=true
            }
            .alert("Copied User ID", isPresented: $copied) {
                Button("Ok", role: .cancel) {
                    copied = false
                }
            }
            
            //Profile buttons
        
            //CHANGE USERNAME
            Button("Change Username") {
                newUsername = profile?.username ?? ""
                showingUsernamePrompt = true
                
            }
            .foregroundColor(.darkgreen)
            .padding(10)
            .background(Color.white)
            .cornerRadius(15)
            .alert("New username", isPresented: $showingUsernamePrompt) {
                TextField("Username", text: $newUsername)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    FirestoreService.shared.updateUsername(newUsername) { err in
                        if let err = err {
                            print("failed to update:", err)
                        }
                    }
                }
            } message: {
                Text("Enter a new username")
            }
        
            //Change EMAIL BUTTON
            Button("Change Email") {
                authModel.changeEmailFlow()
                showingEmailPrompt = true
            }
            .foregroundColor(.darkgreen)
            .padding(10)
            .background(Color.white)
            .cornerRadius(15)
            .sheet(isPresented: $showingEmailPrompt) {
                ChangeEmailSheet(show: $showingEmailPrompt)
                .environmentObject(authModel)
            }
            //CHANGE PASSWORD BUTTON
            Button("Change Password") {
                authModel.changePasswordFlow()
                showingPasswordPrompt = true
            }
            .foregroundColor(.darkgreen)
            .padding(10)
            .background(Color.white)
            .cornerRadius(15)
            .sheet(isPresented: $showingPasswordPrompt) {
              ChangePasswordSheet(show: $showingPasswordPrompt)
                .environmentObject(authModel)
            }
            
            // LOG OUT BUTTON
            Button("Log Out") { authModel.logoutUser() }
                .foregroundColor(.white)
                .padding(10)
                .background(Color.blue)
                .cornerRadius(15)
            
            // DELETE ACCOUNT BUTTON
            Button("Delete Account")  { authModel.deleteAccount() }
                .bold()
                .foregroundColor(.white)
                .padding(10)
                .background(Color.red)
                .cornerRadius(15)
                .alert("Are you sure?", isPresented: $authModel.showDeleteAccountAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        authModel.deleteAccountConfirmed { error in
                            if let e = error {
                                print("Delete failed:", e)
                            }
                        }
                    }
                } message: {
                    Text("This will permanently remove your account.")
                }
                
            Spacer()
            
            Button("View Friend List") {
                showingFriendsList = true
            }
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.white)
            .padding(10)
            .background(Color.darkgreen)
            .cornerRadius(15)
            .sheet(isPresented: $showingFriendsList) {
                FriendList().environmentObject(authModel)
                    .introspect(.navigationStack, on: .iOS(.v16, .v17, .v18)) {
                        $0.viewControllers.forEach { $0.view.backgroundColor = .clear }
                    }
            }
            Spacer()
        }
        .padding(30)
        .frame(width: 350, height: 650)
        .background(Color.accentColor)
        .cornerRadius(50)
        .onAppear { loadProfile() }
        .navigationTitle("My Profile")
    }

    private func loadProfile() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            profile = UserProfile(
              uid:      "preview-uid",
              email:    "preview@example.com",
              username: "PreviewUsername",
              profileImageURL: "",
              friends:  ["friendA","friendB"]
            )
            return
        }
        #endif
        
        guard (Auth.auth().currentUser?.uid) != nil else {
            return
        }
        
        FirestoreService.shared.db
          .collection("users")
          .document(Auth.auth().currentUser!.uid)
          .addSnapshotListener { snap, _ in
            if let d = snap?.data() {
              profile = UserProfile(
                uid: Auth.auth().currentUser!.uid,
                email: d["email"] as! String,
                username: d["username"] as! String,
                profileImageURL: d["profileImageURL"] as! String,
                friends: d["friends"] as! [String])
            }
          }
    }

    private func uploadPicked() {
        guard let img = selectedImage, let data = img.jpegData(compressionQuality: 0.8) else { return }
        let uid = Auth.auth().currentUser!.uid
        StorageService.shared.uploadProfileImage(data, for: uid) { result in
            switch result {
            case .success(let url):
                FirestoreService.shared.updateProfileImageURL(url.absoluteString)
            case .failure(let error):
                print(error)
            }
        }
    }
}


struct UserProfile {
    var uid: String
    var email: String
    var username: String
    var profileImageURL: String
    var friends: [String]
}

// MARK: –– Email sheet
struct ChangeEmailSheet: View {
  @Binding var show: Bool
  @EnvironmentObject var authModel: AuthModel

  var body: some View {
    NavigationStack {
      Form {
        SecureField("Current email", text: $authModel.currentEmail)
        TextField  ("New email", text: $authModel.newEmail)
          .keyboardType(.emailAddress)
          .autocapitalization(.none)
        TextField  ("Confirm new email", text: $authModel.confirmEmail)
          .keyboardType(.emailAddress)
          .autocapitalization(.none)

        if let err = authModel.emailError {
          Text(err).foregroundColor(.red).font(.caption)
        }
      }
      .navigationTitle("Change Email")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { show = false }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
              authModel.updateEmail(to: authModel.confirmEmail) { error in
              if let e = error {
                authModel.emailError = e.localizedDescription
              } else {
                show = false
              }
            }
          }
          // disable until all fields nonempty and match
          .disabled(
            authModel.currentPassword.isEmpty ||
            authModel.newEmail.isEmpty     ||
            authModel.newEmail != authModel.confirmEmail
          )
        }
      }
    }
  }
}

// MARK: –– Password sheet
struct ChangePasswordSheet: View {
    @Binding var show: Bool
    @EnvironmentObject var authModel: AuthModel

    var body: some View {
        NavigationStack {
            Form {
                SecureField("Current password",  text: $authModel.currentPassword)
                SecureField("New password",      text: $authModel.newPassword)
                SecureField("Confirm password",  text: $authModel.confirmPassword)

                if let err = authModel.passwordError {
                  Text(err).foregroundColor(.red).font(.caption)
                }
                
            }
//            .frame(height: 300)
            .navigationTitle("Change Password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                  Button("Cancel") { show = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        authModel.updatePassword(to: authModel.confirmPassword) { error in
                            if let e = error {
                                authModel.passwordError = e.localizedDescription
                            } else {
                                show = false
                            }
                        }
                    }
                    .disabled(
                        authModel.currentPassword.isEmpty ||
                        authModel.newPassword.isEmpty     ||
                        (authModel.newPassword != authModel.confirmPassword)
                      )
                }
            }
        }
    }
}




#Preview {
    ProfileView().environmentObject(AuthModel())
}
