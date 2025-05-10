//
//  TimeLogicTests.swift
//  FastHabbit
//
//  Created by Amy  on 30/04/2025.
//


import XCTest
@testable import FastHabbit

final class TimerLogicTests: XCTestCase {
  
    // end in one hour
    func testDisplayedTime_beforeEnd() {
        let now   = Date()
        let end   = now.addingTimeInterval(3600)// in one hour
        let timer = TimerLogic(start: now, end: end, now: now)

        XCTAssertEqual(timer.displayedTime, "01:00:00\nremaining")
    }

    // ends 30s aftter deadline
    func testDisplayedTime_afterEnd() {
        let start = Date().addingTimeInterval(-3600) // hour ago
        let end   = Date().addingTimeInterval(0) // ended now
        let timer = TimerLogic(start: start, end: end, now: end.addingTimeInterval(30))

        XCTAssertEqual(timer.displayedTime, "01:00:30\n(+00:00:30)")
    }
    
    // ended right on time
    func testDisplayedTime_exactlyZero() {
        let start = Date().addingTimeInterval(3600) // hour ago
        let end   = Date().addingTimeInterval(0) // ended now
        let timer = TimerLogic(start: start, end: end, now: Date())

        XCTAssertEqual(timer.displayedTime, "00:00:00")
    }

    //exactly the middle = just got to stage 3
    func testFlowerStage() {
        let start = Date() //now
        let end = start.addingTimeInterval(100) // 100s long
        // halfway = 50s = 50%
        // stage = Int(0.5*4)+1 = 3
        let halfway = start.addingTimeInterval(50)
        let timer = TimerLogic(start: start, end: end, now: halfway)

        XCTAssertEqual(timer.flowerStage, 3)
    }
}
