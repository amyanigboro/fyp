//
//  Fast.swift
//  FastHabbit
//
//  Created by Amy  on 26/03/2025.
//

import SwiftUI

//create a class that stores details about a recorded fast
class Fast: Encodable {
    var id: String
    var startDate: Date
    var endDate: Date
    var isComplete: Bool
    var flowerEarned: String
    var duration: Double
    
    init(startDate: Date, endDate: Date, isComplete: Bool, flowerEarned: String) {
        self.id = UUID().uuidString
        self.startDate = startDate
        self.endDate = endDate
        self.isComplete = isComplete
        self.flowerEarned = flowerEarned
        self.duration = startDate.distance(to: endDate)
    }
    
    func adjustStartDate(_ newStartDate: Date) {
        self.startDate = newStartDate
        self.duration = startDate.distance(to: endDate)
    }
    
    func adjustEndDate(_ newEndDate: Date) {
        self.endDate = newEndDate
        self.duration = startDate.distance(to: endDate)
    }
}
