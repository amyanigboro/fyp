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
                //remove from user defaults if there no starttime
                UserDefaults.standard.removeObject(forKey: "fastStart")
            }
        }
    }
    
    @Published var flower: String {
        didSet { //stores flower colour
            UserDefaults.standard.set(flower, forKey: "flowerType")
        }
    }
    
    @Published var durationHours: Double {
        didSet { //stores fast duration in user defualts
            UserDefaults.standard.set(durationHours, forKey: "fastDuration")
        }
    }
    
    init() {
        // restore from user defaults
        if let savedStart = UserDefaults.standard.value(forKey: "fastStart") as? Date {
            startTime = savedStart
        }
//        if let savedCol = UserDefaults.standard.string(forKey: "flowerColour") {
//            flowerColour = savedCol
//        }

        durationHours = UserDefaults.standard.double(forKey: "fastDuration")
        
        flower = UserDefaults.standard.string(forKey: "flowerType") ?? "Red"
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
    
    func chooseFlower(colour: String) {
        flower = colour
    }
    
}
