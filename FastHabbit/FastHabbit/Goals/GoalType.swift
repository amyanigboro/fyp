//
//  GoalType.swift
//  FastHabbit
//
//  Created by Amy  on 29/04/2025.
//
import SwiftUI

enum GoalType: String, Codable, CaseIterable {
    case countByFlower = "Flower" // “Complete N fasts with a specific flower”
    case countByDuration = "Fast length" // “Complete N X>= hour fasts”
    case countInPeriod = "Time range" // “Complete N fasts before Y”
}

struct Goal: Identifiable, Codable {
    var id: String = UUID().uuidString
    var type: GoalType
    var targetCount: Int
    var filterValue: String // e.g red or 18
    var startDate: Date // for period goals
    var endDate: Date? // for period goals
    var createdAt: Date = Date()
    var completedAt: Date? //check if it is finished

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
                return "Complete \(targetCount) fast between \(createdAt.formatted(.dateTime.day().month(.wide).year())) and \(endDate.formatted(.dateTime.day().month(.wide).year()))"
            }
        }
        else {
            if type == .countByFlower {
                return "Harvest \(targetCount)\(" " + filterValue.capitalized) flowers"
            } else if type == .countByDuration {
                return "Complete \(targetCount) \(filterValue)-hour fasts"
            } else {
                guard let endDate = endDate else { return "[unspecified]" }
                return "Complete \(targetCount) fasts between \(createdAt.formatted(.dateTime.day().month(.wide).year())) and \(endDate.formatted(.dateTime.day().month(.wide).year()))"
            }
        }
    }
}
