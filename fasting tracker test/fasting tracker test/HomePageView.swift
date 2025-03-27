//
//  FrontPageView.swift
//  fasting tracker test
//
//  Created by Amy  on 07/02/2025.
//

import SwiftUI
import FirebaseAuth

struct HomePageView: View {
    @EnvironmentObject var authModel: AuthModel
    @State private var selectedTab: String = "home"
    
    var body: some View {
        ZStack {
            Image("HomePage")
                .resizable()
                .ignoresSafeArea()

                
            VStack {
                //the top bar stuff
                
//                HStack {}
                //clock timer
                
                //clock timer adjusting mechanisms
                
                //navbar
                Spacer()
                //logic
                if selectedTab == "home" {
                    Button(action: {}) {
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .tint(.darkgreen)
                    }
                    Spacer()
                } else if selectedTab == "timer" {
                    FastingTimerView()
                } else if selectedTab == "profile" {
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
                    Spacer()
                }
                
                HStack(alignment: .bottom, spacing: 85) {
                    Button(action: {
                        selectedTab="home"
                    }) {
                        Image(systemName: "house.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(selectedTab == "home" ? .blue : .gray)
                    }
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
        }
    }
}

#Preview {
    HomePageView().environmentObject(AuthModel())
}

