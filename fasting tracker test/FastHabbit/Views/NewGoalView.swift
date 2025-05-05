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
    @State private var filterValue = ""
    @State private var startDate = Date()
    @State private var endDate = Date()

    var onDone: () -> Void

    var body: some View {
        NavigationStack {
            VStack {
                VStack{
                    Text("How do you want to measure this goal?")
                        .multilineTextAlignment(.center)
                    Picker("", selection: $type) {
                        ForEach(GoalType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .background(Color.green)
                    .pickerStyle(.segmented)
                }
                .padding(20)
                .background(Color.accentColor)
                .cornerRadius(20)

                VStack {
                    Stepper("Target number of fasts: \(targetCount)", value: $targetCount, in: 1...100)
                  
                    switch type {
                        case .countByFlower:
//                            Menu {
//                                Button("Red") {
//                                    filterValue = "Red"
//                                }
//                                Button("Pink") {
//                                    filterValue = "Pink"
//                                }
//                                Button("Blue") {
//                                    filterValue = "Blue"
//                                }
//                                Button("Orange") {
//                                    filterValue = "Orange"
//                                }
//                                Button("Purple") {
//                                    filterValue = "Purple"
//                                }
//                            } label: {
//                                Label("Choose Flower", systemImage: "leaf.fill")
//                                    .frame(width: 200, height:50)
//                                    .background(.accent)
//                                    .tint(.darkgreen)
//                                    .cornerRadius(10)
//                                
//                            }
                        Picker("Flower Type", selection: $filterValue) {
                            Text("Red").tag("Red")
                            Text("Blue").tag("Blue")
                        }
//                            TextField("Flower (e.g. Red)", text: $filterValue)
                        case .countByDuration:
                            TextField("Min hours (e.g. 18)", text: $filterValue)
                            .keyboardType(.decimalPad)
                        case .countInPeriod:
                            DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                            DatePicker("End date",   selection: $endDate,   displayedComponents: .date)
                    }
                }
                Spacer()
            }
            .background(Color.gray)
            .font(.custom("Jua", size:20))
            .navigationTitle("New Goal")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let goal = Goal(
                            type: type,
                            targetCount: targetCount,
                            filterValue: filterValue,
                            startDate: startDate,
                            endDate: type == .countInPeriod ? endDate : nil
                        )
                        FirestoreService.shared.saveGoal(goal) { _ in
                            onDone()
                            dismiss()
                        }
                    }
                    .disabled(filterValue.isEmpty && type != .countInPeriod)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NewGoalView() {
        var showingNew = false
    }

}
