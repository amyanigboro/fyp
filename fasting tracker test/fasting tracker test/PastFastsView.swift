//
//  PastFastsView.swift
//  FastHabbit
//
//  Created by Amy  on 14/03/2025.
//


import SwiftUI

struct PastFastsView: View {
    @State private var pastFasts: [FastLogEntry] = [
        // Example data
        FastLogEntry(start: Date().addingTimeInterval(-36000),
                     end: Date().addingTimeInterval(-18000),
                     hours: 5,
                     flower: "pink")
    ]

    var body: some View {
        List {
            ForEach(pastFasts) { fast in
                VStack(alignment: .leading) {
                    Text("Fasted for \(fast.hours) hours")
                        .font(.headline)
                    Text("Start: \(fast.start.formatted(date: .abbreviated, time: .shortened))")
                    Text("End:   \(fast.end.formatted(date: .abbreviated, time: .shortened))")
                    Text("Flower: \(fast.flower)")
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Past Fasts")
        .toolbar {
            // Button to add a retrospective fast
            Button("Add Fast") {
                // show a sheet or navigate to a form for adding a new fast
            }
        }
    }
}

struct FastLogEntry: Identifiable {
    let id = UUID()
    let start: Date
    let end: Date
    let hours: Int
    let flower: String
}
