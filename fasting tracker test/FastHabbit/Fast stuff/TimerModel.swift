//
//  TimerModel.swift
//  FastHabbit
//
//  Created by Amy  on 28/04/2025.
//


import SwiftUI

final class TimerModel: ObservableObject {
    @Published var startTime: Date? {
        didSet {
            //if start time exists
            if let date = startTime {
                //store in user defaults
                UserDefaults.standard.set(date, forKey: "fastStart")
            } else {
                //remove from user defaults if there is no startTime
                UserDefaults.standard.removeObject(forKey: "fastStart")
            }
        }
    }
    @Published var durationHours: Double {
        didSet { //stores duration in user defualts
            UserDefaults.standard.set(durationHours, forKey: "fastDuration")
        }
    }
    
    init() {
        // restore from UserDefaults
        if let saved = UserDefaults.standard.value(forKey: "fastStart") as? Date {
            startTime = saved
        }
        durationHours = UserDefaults.standard.double(forKey: "fastDuration")
    }
    
    //calculates endtime
    var endTime: Date? {
        guard let s = startTime else { return nil }
        return s.addingTimeInterval(Double(durationHours) * 3600)
    }
    
    
    var isActive: Bool { startTime != nil }
    
    func startFast(hours: Double) {
        startTime = Date()
        durationHours = hours
    }
    
    func reset() {
        startTime = nil
        durationHours = 0
    }
}
