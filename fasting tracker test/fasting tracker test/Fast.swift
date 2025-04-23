//
//  Fast.swift
//  FastHabbit
//
//  Created by Amy  on 26/03/2025.
//

import SwiftUI

//stores details about a recorded fast
struct Fast: Codable, Identifiable {
    var id: String
    var startDate: Date
    var endDate: Date
    var isComplete: Bool
    var flowerEarned: String
    var duration: Double
    var sethours: Double
    
    init(id: String, startDate: Date, endDate: Date, isComplete: Bool, flowerEarned: String, duration: Double, sethours: Double) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.isComplete = isComplete
        self.flowerEarned = flowerEarned
        self.duration = startDate.distance(to: endDate)
        self.sethours = sethours
    }
    
    mutating func adjustStartDate(_ newStartDate: Date) {
        self.startDate = newStartDate
        self.duration = startDate.distance(to: endDate)
    }
    
    mutating func adjustEndDate(_ newEndDate: Date) {
        self.endDate = newEndDate
        self.duration = startDate.distance(to: endDate)
    }
}
