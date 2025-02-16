//
//  FrontPageView.swift
//  fasting tracker test
//
//  Created by Amy  on 07/02/2025.
//

import SwiftUI
import FirebaseAuth

struct HomePageView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Image("HomePage")
                .resizable()
                .ignoresSafeArea()

                
            VStack {
                //the top bar stuff
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Sign Out")
                        .font(Font.custom("Baloo 2", size: 48))
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: 150)
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                HStack {}
                //clock timer
                
                //clock timer adjusting thingies
                
                //navbar
                HStack {}
                
            }
            
        }
    }
}

#Preview {
    HomePageView().environmentObject(AuthViewModel())
}

