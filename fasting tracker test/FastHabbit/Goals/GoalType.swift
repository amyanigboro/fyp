//
//  GoalType.swift
//  FastHabbit
//
//  Created by Amy  on 29/04/2025.
//
import SwiftUI

enum GoalType: String, Codable, CaseIterable {
    case countByFlower = "Flower"     // “Complete N fasts with a given flower”
    case countByDuration = "Fast length"  // “Complete N fasts of >= X hours”
    case countInPeriod = "Time range"    // “Complete N fasts within a date range”
}

var dict = [
    "Flower": "Complete N fasts with a given flower",
    "Fast length": "Complete N fasts of ≥ X hours",
    "Time range": "Complete N fasts within a date range"
]

struct Goal: Identifiable, Codable {
    var id: String = UUID().uuidString
    var type: GoalType
    var targetCount: Int
    var filterValue: String   // e.g. “Red” or “18” or “week”
    var startDate: Date       // for type==.countInPeriod
    var endDate: Date?        // optional for period goals
    var createdAt: Date = Date()

    //if the goal is complete
    var isComplete: Bool {
        progress >= targetCount
    }

    //to be adjusted
    var progress: Int = 0 // 0 by default

    var typeDescription: String {
        if targetCount == 1 {
            if type == .countByFlower {
                return "Harvest \(targetCount)\(" " + filterValue.capitalized) flower"
            } else if type == .countByDuration {
                return "Complete \(targetCount) \(filterValue)-hour fast"
            } else {
                guard let endDate = endDate else { return "[unspecified]" }
                return "Complete \(targetCount) fast before \(endDate.formatted(.dateTime.day().month(.wide).year()))"
            }
        }
        else {
            if type == .countByFlower {
                return "Harvest \(targetCount)\(" " + filterValue.capitalized) flowers"
            } else if type == .countByDuration {
                return "Complete \(targetCount) \(filterValue)-hour fasts"
            } else {
                guard let endDate = endDate else { return "[unspecified]" }
                return "Complete \(targetCount) fasts before \(endDate.formatted(.dateTime.day().month(.wide).year()))"
            }
        }
    }
}
