//
//  FriendList.swift
//  FastHabbit
//
//  Created by Amy  on 24/04/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import SwiftUIIntrospect

struct FriendList: View {
    @State private var profile: UserProfile?
    @EnvironmentObject var authModel: AuthModel
//    @State private var incoming: [String] = []
//    @State private var friendUN = ""
    @StateObject private var flm = FriendListModel()
    
    var body: some View {
        Section{
            NavigationStack{
                addfriend
                friendslist
                requests
            }
            .introspect(.navigationStack, on: .iOS(.v16, .v17, .v18)) {
                $0.viewControllers.forEach { $0.view.backgroundColor = .clear }
            }
            .background(Color.gray)
            
            

        }
        .onAppear {
            flm.start()
            loadProfile()
        }
        .onDisappear { flm.stop() }
        .font(Font.custom("Jua", size: UIFont.preferredFont(forTextStyle: .body).pointSize))
        
    }
    
    private var addfriend: some View {
        NavigationLink("Add New Friend") {
            AddFriendView()
        }
        .padding(15)
        .background(Color.white.opacity(0.2))
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
    
    private var friendslist: some View {
        ScrollView{
            VStack {
                ForEach(flm.friends, id:\.self) { uid in
                    FriendRow(
                        uid: uid,
                        name: flm.namesByUID[uid] ?? uid
                      )
                        .padding(10)
                        .frame(width:300, height: 60)
                        .background(Color.accentColor)
                        .cornerRadius(20)
                }
            }
        }
        .offset(y:20)
    }
    
    private var requests: some View {
        VStack {
            Text("Pending Requests")
            if flm.incoming.isEmpty {
                Text("No requests").font(.caption)
                    .padding(20)
            } else {
                ForEach(flm.incoming, id:\.self) { uid in
                    HStack {
                        let hi = flm.namesByUID[uid] ?? uid
                        Text(hi.prefix(16))
                        Spacer()
                        Button("Accept") {
                            flm.accept(uid)
                        }
                        .foregroundColor(.darkgreen)
                        Button("Decline", role: .destructive) {
                            flm.decline(uid)
                        }
                    }
                    .padding(10)
                    .frame(width:300, height: 60)
                    .background(Color.accentColor)
                    .cornerRadius(20)
                }
            }
            
        }
        .padding(20)
    }
    
    func loadProfile() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            profile = UserProfile(
              uid:      "preview-uid",
              email:    "preview@example.com",
              username: "PreviewUsername",
              profileImageURL: "",
              friends:  ["friendA","friendB","friendC"]
            )
            return
        }
        #endif
    }
}

struct FriendRow: View {
    let uid: String
    let name: String
    @StateObject private var flm = FriendListModel()
    var body: some View {
        HStack {
            Menu {
                Button("Remove Friend", role: .destructive) {
                    flm.remove(uid)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .padding(10)
            }
            Text(name.prefix(16))
                .font(.custom("Jua", size:20))
                .fontWeight(.thin)
            Spacer()
            Button {
                AudioServicesPlaySystemSound(1120)
                flm.sendPing(uid)

            }
            label: {
                Text("Ping")
                .bold()
                .font(Font.custom("Jua", size: 18))
                .foregroundColor(.darkgreen)
                
                Image(systemName: "bell.fill")
                .foregroundColor(Color.gray)
//                .padding(10)
                    
            }
            .padding(10)
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
            
        }
    }
}

struct AddFriendView: View {
    @State private var targetUID = ""
    @State private var feedback: String?
//    @EnvironmentObject var authModel: AuthModel
    @StateObject private var flm = FriendListModel()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter user’s UID", text: $targetUID)
                  .autocapitalization(.none)

                Button("Send Request") {
                    flm.sendRequest(to: targetUID)
                }
                .disabled(targetUID.count != 28) // or whatever the UID length is

                if let fb = feedback {
                  Text(fb)
                    .foregroundColor(fb.hasPrefix("Error") ? .red : .green)
                    .font(.caption)
                }
            }
            .navigationTitle("Add Friend")
        }
    }
}


#Preview {
    FriendList().environmentObject(AuthModel())
}
