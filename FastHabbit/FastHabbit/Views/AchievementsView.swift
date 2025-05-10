//
//  AchievementsView.swift
//  FastHabbit
//
//  Created by Amy  on 28/04/2025.
//

import SwiftUI
import FirebaseFirestore

struct AchievementsView: View {
    @State private var fasts: [Fast] = []
    let countfasts: [Int] = [1,10,25,50] //can expand to more in future
    
    var body: some View {
        ScrollView{
            ForEach(countfasts, id: \.self){achievement in
                VStack{
                    if UIImage(named: "\(achievement) fast achieve") != nil {
                        //if the user has that number of fasts
                        if self.fasts.filter({$0.isComplete}).count >= achievement {
                            //show the color one
                            Image("\(achievement) fast achieve")
                                .resizable()
                                .scaledToFit()
                        } else { //else show the greyscale
                            Image("Greyscale\(achievement)")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 680)
        .padding(30)
        .onAppear {
            loadFasts()
        }
    }
    
    private func loadFasts() {
        FirestoreService.shared.fetchAll { loaded in
            print("fetched \(loaded.count) fasts from Firestore")
//            fasts = loaded.sorted { $0.startDate > $1.startDate }
            DispatchQueue.main.async {
                self.fasts = loaded
            }
        }
    }
}

#Preview {
    AchievementsView()
}
