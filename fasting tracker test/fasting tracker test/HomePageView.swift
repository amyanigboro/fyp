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
    @State private var selectedTab: String = "home"
    
    var body: some View {
        ZStack {
            Image("HomePage")
                .resizable()
                .fixedSize(horizontal: false, vertical: false)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity)
                
//                .scaledToFit()
                

                
            VStack {
                //the top bar stuff
                
//                HStack {}
                //clock timer
                
                //clock timer adjusting mechanisms
                
                //navbar
//                NavigationStack{
//                    NavigationLink("View Past Fasts", destination: PastFasts())
//                    .padding(.top)
//                }
//                .introspect(.navigationStack, on: .iOS(.v16, .v17, .v18)) {
//                    $0.viewControllers.forEach { controller in
//                        controller.view.backgroundColor = .clear
//                    }
//                }
//                Spacer()
                
                //maincontent
                if selectedTab == "home" {
                    NavigationStack{
                        NavigationLink(destination:
                            PastFasts()
                            .introspect(.viewController, on: .iOS(.v16, .v17, .v18)) { vc in
                                vc.view.backgroundColor = .clear
                            }
                        ) {
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .tint(.darkgreen)
                                .padding(.top)
                        }
//                        .buttonStyle(.plain)
                    }
                    .introspect(.navigationStack , on: .iOS(.v16, .v17, .v18)) {
                        $0.viewControllers.forEach { controller in
                            controller.view.backgroundColor = .clear
                        }
                    }
//                    NavigationStack{
//                        NavigationLink("View Past Fasts", destination: PastFasts())
//                    }
                    Spacer()
                }
                else if selectedTab == "timer" {
                    FastingTimerView()
                }
                else if selectedTab == "profile" {
                    Button(action: {
                        authModel.logoutUser()
                    }) {
                        Text("Sign Out")
                            .font(Font.custom("Baloo 2", size: 24))
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: 150)
                            .background(Color(hue: 0.547, saturation: 0.649, brightness: 0.766))
                            .foregroundColor(Color.white)
                            .cornerRadius(30)
                    }
//                    Spacer()
                }
                
            }
            
           
            NavigationStack(){
                HStack(alignment: .bottom, spacing: 85) {
                    
                    Button(action: {
                        selectedTab="timer"
                    }) {
                        Image(systemName: "timer")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(selectedTab == "timer" ? .blue : .gray)
                    }
                    
                    Button(action: {
                        selectedTab="home"
                    }) {
                        Image(systemName: "leaf.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(selectedTab == "home" ? .blue : .gray)
                    }
                    
                    Button(action: {
                        selectedTab="profile"
                    }) {
                        Image(systemName: "house.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(selectedTab == "profile" ? .blue : .gray)
                    }
                }
            }
            .frame(width: 350, height: 200, alignment: .bottom)
            .offset(x: -2, y:380)
            .introspect(.navigationStack, on: .iOS(.v16, .v17, .v18)) {
                $0.viewControllers.forEach { controller in
                    controller.view.backgroundColor = .clear
                }
            }
        }
    }
}

#Preview {
    HomePageView().environmentObject(AuthModel())
}

