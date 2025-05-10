//
//  EditFastView.swift
//  FastHabbit
//
//  Created by Amy  on 22/04/2025.
//
import SwiftUI

struct EditFastView: View {
    @State private var draftFast: Fast
    @State private var showInvalidFastAlert = false
    
    var onSave: (Fast) -> Void
    @Environment(\.dismiss) private var dismiss

    init(fast: Fast, onSave: @escaping (Fast) -> Void) {
        _draftFast = State(initialValue: fast)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Dates") {
                    DatePicker("Start", selection: $draftFast.startDate, in: ...Date())
                    DatePicker("End", selection: $draftFast.endDate, in: ...Date())
                }
            }
            .navigationTitle("Edit Fast")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard draftFast.startDate <= draftFast.endDate else {
                            showInvalidFastAlert = true
                            return
                        }

                        // recalc duration & completeness
                        draftFast.duration = draftFast.startDate.distance(to: draftFast.endDate)
                        draftFast.isComplete = draftFast.duration >= draftFast.sethours
                        onSave(draftFast)
                        dismiss()
                    }
                    .tint(.lightgreen)
                    .alert("Invalid Fast", isPresented: $showInvalidFastAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Pick an end time that comes after your start time.")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.lightgreen)
                }
            }
        }
    }
}

#Preview {
    EditFastView(fast: Fast(id: "ABCDE", startDate: Date.now, endDate: Date.now, isComplete: true, flowerEarned: "Blue", duration: 1.2, sethours: 16), onSave: { _ in })
}
