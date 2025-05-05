import XCTest
@testable import FastHabbit

final class GoalStoreTests: XCTestCase {
  var now: Date!

  override func setUp() {
    super.setUp()
    now = Date()
  }

  func makeFast(_ flower: String, hours: Double, complete: Bool) -> Fast {
    let start = now.addingTimeInterval(-hours*3600)
    let end   = now
    return Fast(id: "x", startDate: start, endDate: end,
                isComplete: complete, flowerEarned: flower,
                duration: hours*3600, sethours: hours)
  }

  func testCountByFlower() {
    let f1 = makeFast("Red", hours: 16, complete: true)
    let f2 = makeFast("Red", hours: 16, complete: false)
    let f3 = makeFast("Blue", hours: 16, complete: true)
    let goal = Goal(type: .countByFlower, filterValue: "Red",
                    targetCount: 1, startDate: now, endDate: nil)
    let store = GoalStore()
    XCTAssertEqual(store.calculateProgress(for: goal, in: [f1,f2,f3]), 1)
  }
  
  func testCountByDuration() {
    let f1 = makeFast("Red", hours: 18, complete: true)
    let f2 = makeFast("Red", hours: 16, complete: true)
    let goal = Goal(type: .countByDuration, filterValue: "17",
                    targetCount: 1, startDate: now, endDate: nil)
    let store = GoalStore()
    XCTAssertEqual(store.calculateProgress(for: goal, in: [f1,f2]), 1)
  }

  func testCountInPeriod() {
    let yesterday = now.addingTimeInterval(-24*3600)
    let f1 = Fast(id: "a", startDate: yesterday, endDate: yesterday.addingTimeInterval(100),
                  isComplete: true, flowerEarned: "Any", duration: 100, sethours: 0)
    let goal = Goal(type: .countInPeriod, filterValue: "",
                    targetCount: 1, startDate: yesterday, endDate: now)
    let store = GoalStore()
    XCTAssertEqual(store.calculateProgress(for: goal, in: [f1]), 1)
  }
}
