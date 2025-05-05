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
                    .cornerRadius(5)
                    .pickerStyle(.segmented)
                }
                .padding(20)
                .background(Color.accentColor)
                .cornerRadius(20)

                VStack {
                    Stepper("Target number of fasts: \(targetCount)", value: $targetCount, in: 1...100)
                  
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
                                    .background(.accent)
                                    .tint(.darkgreen)
                                    .padding(10)
                                    .cornerRadius(10)
                                
                            }
//                            Picker("Flower Type", selection: $filterValue) {
//                                Text("Red").tag("Red")
//                                Text("Blue").tag("Blue")
//                                Text("Pink").tag("Pink")
//                                Text("Orange").tag("Orange")
//                                Text("Purple").tag("Purple")
//                            }
//                            TextField("Flower (e.g. Red)", text: $filterValue)
                        case .countByDuration:
//                            TextField("Min hours (e.g. 18)", text: $filterValue)
//                                .keyboardType(.decimalPad)
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
                                Label("Min Fast Length: \(filterValue)", systemImage: "timer.fill")
                                    .frame(height:50)
                                    .background(.accent)
                                    .tint(.darkgreen)
                                    .padding(10)
                                    .cornerRadius(10)

                            }
                        case .countInPeriod:
                            DatePicker("End date", selection: $endDate,   displayedComponents: .date)
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
    NewGoalView() {}

}
