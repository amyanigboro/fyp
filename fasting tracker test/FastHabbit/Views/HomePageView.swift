//
//  FrontPageView.swift
//  fasting tracker test
//
//  Created by Amy  on 07/02/2025.
//

import SwiftUI
import FirebaseAuth
import SwiftUI
import SwiftUIIntrospect

struct HomePageView: View {
    @EnvironmentObject var authModel: AuthModel
    @StateObject private var timer = TimerModel()

    @State private var selectedTab = Tab.home
    @State private var needsProfile = false
    enum Tab { case home, timer, profile }
    
    var body: some View {
        ZStack {
            Image("HomePage")
                .resizable()
                .fixedSize(horizontal: false, vertical: false)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity)
            
            
            VStack {
                contentView
                Spacer()
                tabBar
            }
            .onAppear {
                authModel.checkProfile { ok in
                    needsProfile = !ok
                }
            }
            .sheet(isPresented: $needsProfile) {
                CreateProfileView(onDone: {
                    needsProfile = false
                })
            }
            
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .home:
            NavigationStack() {
                linktogarden
                linktogoals
                linktoachievements
                linktonotifs
            }
            .tint(.darkgreen)
            .introspect(.navigationStack, on: .iOS(.v16, .v17, .v18)) {
                $0.viewControllers.forEach { $0.view.backgroundColor = .clear }
            }
        case .timer:
//            Spacer()
            FastingTimerView()
                .environmentObject(timer)
//                .frame(width: 200)
//                .offset(y: 50)

        case .profile:
            ProfileView().environmentObject(authModel)
        }
    }
    
    private var linktogarden: some View {
        NavigationLink {
          GardenView()
            .introspect(.viewController, on: .iOS(.v16, .v17, .v18)) { vc in
              vc.view.backgroundColor = .clear
            }
//            .frame(width: 200, height: 500)
        } label: {
          Image("Enter garden button")
            .resizable().scaledToFit()
            .frame(width: 300, height: 200)
//                    .tint(.darkgreen)
        }
    }
    
    private var linktogoals: some View {
        NavigationLink {
          SetGoalsView()
            .introspect(.viewController, on: .iOS(.v16, .v17, .v18)) { vc in
              vc.view.backgroundColor = .clear
            }
//            .frame(width: 400, height: 500)
        } label: {
          Image("Set goals button")
            .resizable().scaledToFit()
            .frame(width: 310, height: 200)
            .offset(x:5)
//                    .tint(.darkgreen)
        }
    }
    
    private var linktoachievements: some View {
        NavigationLink {
          AchievementsView()
            .introspect(.viewController, on: .iOS(.v16, .v17, .v18)) { vc in
              vc.view.backgroundColor = .clear
            }
//            .frame(width: 400, height: 800)
        } label: {
          Image("Achievements button")
            .resizable().scaledToFit()
            .frame(width: 325, height: 200)
            .offset(x:5)
//                    .tint(.darkgreen)
        }
    }
    
    private var linktonotifs: some View {
        NavigationLink{
            NotificationsView()
            .introspect(.viewController, on: .iOS(.v16, .v17, .v18)) { vc in
              vc.view.backgroundColor = .clear
            }
        } label: {
            Image(systemName: "bell.fill")
                .resizable()
                .frame(width:30, height:30)
        }
        .foregroundColor(.yellow)
        .padding(15)
        .background(Color.gray)
        .cornerRadius(20)
        .offset(x:-150, y:-660)
    }
    
    private var tabBar: some View {
        NavigationStack(){
            HStack(alignment: .bottom, spacing: 85) {
                Button(action: {
                    selectedTab = .timer
                }) {
                    Image(systemName: "timer")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(selectedTab == .timer ? .blue : .gray)
                }
                
                Button(action: {
                    selectedTab = .home
                }) {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(selectedTab == .home ? .blue : .gray)
                }
                
                Button(action: {
                    selectedTab = .profile
                }) {
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(selectedTab == .profile ? .blue : .gray)
                }
            }
        }
        .frame(width: 350, height: 50, alignment: .bottom)
//        .offset(x: 0, y:93)
        .introspect(.navigationStack, on: .iOS(.v16, .v17, .v18)) {
            $0.viewControllers.forEach { controller in
                controller.view.backgroundColor = .clear
            }
        }
    }
}

struct CreateProfileView: View {
    @State private var username = ""
    let onDone: ()->Void

    var body: some View {
        VStack(spacing:20) {
            Text("Choose a Username").font(.headline)
            TextField("e.g. ’lol123’", text: $username)
            .textFieldStyle(.roundedBorder)
            .padding()
            Button("Save") {
            let user = Auth.auth().currentUser!
            FirestoreService.shared.createUserProfile(
              uid: user.uid,
              email: user.email!,
              username: username
            ) { _ in onDone() }
            }
            .disabled(username.count < 3)
        }
        .padding()
        .frame(maxWidth: 300)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    HomePageView().environmentObject(AuthModel())
}

