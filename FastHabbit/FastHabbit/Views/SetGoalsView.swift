//
//  SetGoalsView.swift
//  FastHabbit
//
//  Created by Amy  on 29/04/2025.
//


import SwiftUI

struct SetGoalsView: View {
    @StateObject private var goalstore = GoalStore()
    @State private var showingNew = false

    var body: some View {
        Text("Your Goals")
            .font(.custom("Jua", size: 40))
        ScrollView {
            Button("Add New Goal") {
                showingNew = true
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(15)
            
            if !goalstore.active.isEmpty {
                VStack {
                    Text("Active Goals")
                    ForEach(goalstore.active) { goal in
                        GoalRow(goal: goal)
                            .padding(20)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(10)
                        Button(role: .destructive) {
                            FirestoreService.shared.deleteGoal(goal)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .frame(width:20)
                        .offset(x:145, y:-90)
                    }
                }
                .padding(20)
                .background(Color.orange)
                .cornerRadius(20)
            }

            if !goalstore.complete.isEmpty {
                VStack {
                    Text("Completed Goals")
                    ForEach(goalstore.complete) { goal in
                        GoalRow(goal: goal)
                            .padding(20)
                            .background(Color.green)
                            .cornerRadius(10)
                            .opacity(0.8)
                        
                        Button(role: .destructive) {
                            FirestoreService.shared.deleteGoal(goal)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .frame(width:20)
                        .offset(x:145, y:-90)
                    }
                }
                .padding(20)
                .background(Color.darkgreen)
                .foregroundColor(.white)
                .cornerRadius(20)
            }
        }
        .font(.custom("Jua", size: 16))
        .padding(50)
        .onAppear {
            goalstore.start()
        }
        .onDisappear {
            goalstore.stop()
        }
        .sheet(isPresented: $showingNew) {
            NewGoalView() {
                showingNew = false
            }
        }
        
    }
    
}

struct GoalRow: View {
    let goal: Goal

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(goal.typeDescription) // you can add a computed var for a nice label
                Text("\(goal.progress) / \(goal.targetCount)")
                .font(.caption)
                .foregroundColor(goal.isComplete ? .darkgreen : .orange)
                if let date = goal.completedAt {
                    Text("Completed on: \(date, style: .date)")
                        .foregroundColor(.white)
                        .font(.custom("Jua", size: 12))
                }
            }
            Spacer()
            if goal.isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 4)
    }
}

