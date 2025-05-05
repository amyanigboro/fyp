import XCTest
@testable import FastHabbit    // your app module

final class TimeLogicTests: XCTestCase {
  
  func testDisplayedTime_beforeEnd() {
    // Given a start and an end an hour from now:
    let now   = Date()
    let end   = now.addingTimeInterval(3600)     // +1h
    let vm    = TimerLogic(start: now, end: end, now: now)
    
    XCTAssertEqual(vm.displayedTime, "01:00:00 remaining")
  }

  func testDisplayedTime_afterEnd() {
    let start = Date().addingTimeInterval(-3600)  // 1h ago
    let end   = Date().addingTimeInterval(-0)     // ended now
    let vm    = TimerLogic(start: start, end: end, now: Date().addingTimeInterval(30))
    
    XCTAssertEqual(vm.displayedTime, "+00:00:30 overtime")
  }
  
  func testFlowerStage() {
    let start   = Date()
    let end     = start.addingTimeInterval(100)   // 100s long
    // halfway = 50s → 50% → stage = Int(0.5*4)+1 = 3
    let halfway = start.addingTimeInterval(50)
    let vm      = TimerLogic(start: start, end: end, now: halfway)
    
    XCTAssertEqual(vm.flowerStage, 3)
  }
}
