//
//  EditFastView.swift
//  FastHabbit
//
//  Created by Amy  on 22/04/2025.
//
import SwiftUI

struct EditFastView: View {
  @State private var draftFast: Fast
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
          DatePicker("Start", selection: $draftFast.startDate)
          DatePicker("End",   selection: $draftFast.endDate)
        }
      }
      .navigationTitle("Edit Fast")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            // recalc duration & completeness
            draftFast.duration   = draftFast.startDate.distance(to: draftFast.endDate)
            draftFast.isComplete = draftFast.duration >= draftFast.sethours
            onSave(draftFast)
            dismiss()
          }
          .tint(.accentColor)
        }
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
          .tint(.accentColor)
        }
      }
    }
  }
}

#Preview {
    EditFastView(fast: Fast(id: "ABCDE", startDate: Date.now, endDate: Date.now, isComplete: true, flowerEarned: "Blue", duration: 1.2, sethours: 16), onSave: { _ in })
}
