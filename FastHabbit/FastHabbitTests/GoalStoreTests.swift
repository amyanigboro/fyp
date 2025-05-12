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
    func makeFast(hours: Double = 16, flower: String = "Red", complete: Bool? = nil, start: Date = Date().addingTimeInterval(-16*3600), end: Date = Date(), ago: Double = 16) -> Fast {
        print(hours, abs(end.distance(to:start) / 3600),  hours <= round(abs(end.distance(to:start) / 3600)) )
        let start = start.addingTimeInterval(16*3600-ago*3600)
        let complete = complete ?? (hours <= round( start.distance(to:end) / 3600) )
        
        return Fast(
          id: UUID().uuidString,
          startDate: start, //default 16 hours ago, but ago overrides it
          endDate: end, //default now
          isComplete: complete, //not rearranging the parameters just to make this look nicer
          flowerEarned: flower,
          duration: end.distance(to:start), //calculated actual fast length
          sethours: hours //chosen hours
        )
    }

    //calculate progress with 1/3 eligible flower fast
    func testCountByFlower_OneOfN() {
        let redDone = makeFast(flower: "Red", complete: true)
        let redFailed = makeFast(flower: "Red", complete: false)
        let blueDone = makeFast(flower: "Blue", complete: true)

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
        let redDone = makeFast(flower: "Red", complete: true)
        let redFailed = makeFast(flower: "Red", complete: false)
        let blueDone = makeFast(flower: "Blue", complete: true)

        let goal = Goal(
          type: .countByFlower,
          targetCount: 2,
          filterValue: "Pink", //pink flower
          startDate: Date()// always the current date for now
        )

        XCTAssertEqual(store._test_calculateProgress(for: goal, in: [redDone, redFailed, blueDone]), 0)
    }
    
    //calculate progress with 4/3 eligible flower fast
    func testCountByFlower_ExcessOfN() {
        let pinkOneDone = makeFast(flower: "Pink", complete: true)
        let pinkTwoDone = makeFast(flower: "Pink", complete: true)
        let pinkThreeDone = makeFast(flower: "Pink", complete: true)
        let pinkFourDone = makeFast(flower: "Pink", complete: true)

        let goal = Goal(
          type: .countByFlower,
          targetCount: 3,
          filterValue: "Pink", //pink flower
          startDate: Date()// always the current date for now
        )

        XCTAssertEqual(store._test_calculateProgress(for: goal, in: [pinkOneDone, pinkTwoDone, pinkThreeDone, pinkFourDone]), 4)

    }

    //calculate progress with 1/1 eligible fast length fast
    func testCountByDuration_OneOfN() {
        let eighteen = makeFast(hours: 18, ago: 17) // incomplete ==> ineligible
        let sixteen = makeFast(hours: 16, ago: 17) //eligible

        let goal = Goal(
          type: .countByDuration,
          targetCount: 1,
          filterValue: "17", // 17 hours minimum
          
          startDate: Date()
        )
        print([eighteen, sixteen])

        XCTAssertEqual(store._test_calculateProgress(for: goal, in: [eighteen, sixteen]), 1)
    }
    
    //calculate progress with 1/1 eligible fast length fast
    func testCountByDuration_ZeroOfN() {
        let eighteen = makeFast(hours: 18, ago: 18)
        let sixteen = makeFast(hours: 16, ago: 17)

        let goal = Goal(
          type: .countByDuration,
          targetCount: 1,
          filterValue: "18.4", // 18.4 hours minimum
          
          startDate: Date()
        )

        XCTAssertEqual(store._test_calculateProgress(for: goal, in: [eighteen, sixteen]), 0)
    }
    
    //calculate progress with 2/1 eligible fast length fast
    func testCountByDuration_ExcessOfN() {
        let eighteen = makeFast(hours: 18, ago: 19)
        let sixteen = makeFast(hours: 16, ago: 20)

        let goal = Goal(
          type: .countByDuration,
          targetCount: 1,
          filterValue: "18.4", // 18.4 hours minimum
          
          startDate: Date()
        )

        XCTAssertEqual(store._test_calculateProgress(for: goal, in: [eighteen, sixteen]), 2)
    }

    //calculate progress with 1/1 eligible timerange fast
    func testCountInPeriodOne() {
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
    
    //calculate progress with 2/4 eligible timerange fast
    func testCountInPeriodSome() {
        let tomorrow = Date(timeIntervalSince1970:24*3600)//jan 2 1970 00:00:00
        let today = Date(timeIntervalSince1970:0) //jan 1 00:00:00
        let yesterday = Date(timeIntervalSince1970:-24*3600)

        let passFast = makeFast(start: today,
                                  end: today.addingTimeInterval(8*3600)) //end = jan 1 08:00:00
        let passFast2 = makeFast(start: today,
                                  end: tomorrow.addingTimeInterval(60)) //end = jan 2 00:00:01
        let failFast = makeFast(start: tomorrow,
                                  end: tomorrow.addingTimeInterval(16*3600)) //end = jan 2 16:00:00
        let failFast2 = makeFast(start: yesterday,
                                end: yesterday.addingTimeInterval(32*3600)) //end = jan 1 08:00:00

        
        

        let goal = Goal(
          type: .countInPeriod,
          targetCount: 4,
          filterValue: "",
          
          startDate: today, //goal dates = inclusive of the fasts starting and ending seconds
          endDate: tomorrow
        )

        XCTAssertEqual(store._test_calculateProgress(for: goal, in: [passFast, passFast2, failFast, failFast2]), 2)
    }
}
