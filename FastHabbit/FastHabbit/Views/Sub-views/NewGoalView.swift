//
//  NewGoalView.swift
//  FastHabbit
//
//  Created by Amy  on 29/04/2025.
//

import SwiftUI

struct NewGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var type: GoalType = .countByFlower
    @State private var targetCount = 1
    @State private var filterValue = "None"
    @State private var startDate = Date()
    @State private var endDate = Date()

    var onDone: () -> Void

    var body: some View {
        NavigationStack {
            VStack {
                Text("New Goal")
                    .font(.custom("Jua", size: 30))
                    .foregroundColor(.white)
                VStack{
                    Text("How do you want to measure this goal?")
                        .multilineTextAlignment(.center)
                    Picker("", selection: $type) {
                        ForEach(GoalType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .background(Color.darkgreen.brightness(0.2))
                    .cornerRadius(10)
                    .pickerStyle(.segmented)
                }
                .foregroundColor(.white)
                .padding(20)
                .background(Color.accentColor)
                .cornerRadius(20)

                VStack {
                    Stepper("Target number of fasts: \(targetCount)", value: $targetCount, in: 1...100)
                        .foregroundColor(.white)
                  
                    switch type {
                        case .countByFlower:
                            Menu {
                                Button("Red") {
                                    filterValue = "Red"
                                }
                                Button("Pink") {
                                    filterValue = "Pink"
                                }
                                Button("Blue") {
                                    filterValue = "Blue"
                                }
                                Button("Orange") {
                                    filterValue = "Orange"
                                }
                                Button("Purple") {
                                    filterValue = "Purple"
                                }
                            } label: {
                                Label("Choose Flower: \(filterValue)", systemImage: "leaf.fill")
                                    .frame(height:50)
                                    .padding(10)
                                    .background(.accent)
                                    .tint(.darkgreen)
                                    .cornerRadius(10)
                                
                            }
                        .onAppear { resetFilter() }
                        case .countByDuration:
                            Menu {
                                Button("13") {
                                    filterValue = "13"
                                }
                                Button("16") {
                                    filterValue = "16"
                                }
                                Button("18") {
                                    filterValue = "18"
                                }
                                Button("23") {
                                    filterValue = "23"
                                }
                                Button("36") {
                                    filterValue = "36"
                                }
                            } label: {
                                Label("Min Fast Length: \(filterValue)", systemImage: "hourglass")
                                    .frame(height:50)
                                    .padding(10)
                                    .background(.accent)
                                    .tint(.darkgreen)
                                    .cornerRadius(20)
                            }
                            .onAppear { resetFilter() }
                        case .countInPeriod:
                            DatePicker("End date", selection: $endDate,   in: Date()..., displayedComponents: .date)
                                .foregroundColor(.white)
                                .onAppear { resetFilter() }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Color.lightgreen)
            .font(.custom("Jua", size:20))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let goal = Goal(
                            type: type,
                            targetCount: targetCount,
                            filterValue: filterValue,
                            startDate: startDate, //startDate will be used by other goal types in the future
                            endDate: type == .countInPeriod ? endDate : nil,
                            completedAt: nil
                        )
                        FirestoreService.shared.saveGoal(goal) { _ in
                            onDone()
                            dismiss()
                        }
                    }
                    .disabled(filterValue=="None" && type != .countInPeriod)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func resetFilter() {
        filterValue = "None"
    }
}

#Preview {
    NewGoalView() {}

}
