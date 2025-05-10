import XCTest
@testable import FastHabbit

final class GoalStoreTests: XCTestCase {
    var store: GoalStore!

    override func setUp() {
        super.setUp()
        store = GoalStore()
    }

    // making a fast X hours long
    //helper
    func makeFast(hours: Double, flower: String, complete: Bool, start: Date = Date().addingTimeInterval(-16*3600), end: Date = Date()) -> Fast {
        return Fast(
          id: UUID().uuidString,
          startDate: start, //default 16 hours ago
          endDate: end, //default now
          isComplete: complete,
          flowerEarned: flower,
          duration: end.distance(to:start), //calculated actual fast length
          sethours: hours //chosen hours
        )
    }

    //calculate progress with 1/3 eligible flower fast
    func testCountByFlower_OneOfN() {
        let redDone = makeFast(hours: 16, flower: "Red",  complete: true)
        let redFailed = makeFast(hours: 16, flower: "Red",  complete: false)
        let blueDone = makeFast(hours: 16, flower: "Blue", complete: true)

        let goal = Goal(
          type: .countByFlower,
          targetCount: 2,
          filterValue: "Red", //red flower
          startDate: Date() // always the current date for now
        )

        XCTAssertEqual(store._test_calculateProgress(for: goal, in: [redDone, redFailed, blueDone]), 1)
    }
    
    //calculate progress with 0/3 eligible flower fast
    func testCountByFlower_ZeroOfN() {
        let redDone = makeFast(hours: 16, flower: "Red",  complete: true)
        let redFailed = makeFast(hours: 16, flower: "Red",  complete: false)
        let blueDone = makeFast(hours: 16, flower: "Blue", complete: true)

        let goal = Goal(
          type: .countByFlower,
          targetCount: 2,
          filterValue: "Pink", //pink flower
          startDate: Date()// always the current date for now
        )

        XCTAssertEqual(store._test_calculateProgress(for: goal, in: [redDone, redFailed, blueDone]), 0)
    }

    //calculate progress with 1/1 eligible fast length fast
    func testCountByDuration_OneOfN() {
        let eighteen = makeFast(hours: 18, flower: "Red", complete: true)
        let sixteen = makeFast(hours: 16, flower: "Red", complete: true)

        let goal = Goal(
          type: .countByDuration,
          targetCount: 1,
          filterValue: "17", // 17 hours minimum
          
          startDate: Date(),
          endDate: nil
        )

        XCTAssertEqual(store._test_calculateProgress(for: goal, in: [eighteen, sixteen]), 1)
    }
    
    //calculate progress with 1/1 eligible fast length fast
    func testCountByDuration_ZeroOfN() {
        let eighteen = makeFast(hours: 18, flower: "Red", complete: true)
        let sixteen = makeFast(hours: 16, flower: "Red", complete: true)

        let goal = Goal(
          type: .countByDuration,
          targetCount: 1,
          filterValue: "18.4", // 18.4 hours minimum
          
          startDate: Date(),
          endDate: nil
        )

        XCTAssertEqual(store._test_calculateProgress(for: goal, in: [eighteen, sixteen]), 0)
    }

    //calculate progress with 1/1 eligible timerange fast
    func testCountInPeriod() {
        let tomorrow = Date(timeIntervalSince1970:24*3600)//jan 2 1970 00:00:00
        let today = Date(timeIntervalSince1970:0) //jan 1 00:00:00

        let passFast = makeFast(hours: 8,
                                  flower: "Pink",
                                  complete: true,
                                  start: today,
                                  end: today.addingTimeInterval(8*3600)) //end = jan 1 08:00:00

        let goal = Goal(
          type: .countInPeriod,
          targetCount: 1,
          filterValue: "",
          
          startDate: today, //goal dates = inclusive of the fasts starting and ending seconds
          endDate: tomorrow
        )

        XCTAssertEqual(store._test_calculateProgress(for: goal, in: [passFast]), 1)
    }
}
