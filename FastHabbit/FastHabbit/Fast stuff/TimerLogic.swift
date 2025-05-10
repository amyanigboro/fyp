//
//  TimerLogic.swift
//  FastHabbit
//
//  Created by Amy  on 30/04/2025.
//

import Foundation

// countdown formatting + stage calc
public struct TimerLogic {
    public let start: Date?
    public let end:   Date?
    public let now:   Date

    public init(start: Date, end: Date, now: Date) {
        self.start = start
        self.end   = end
        self.now   = now
    }

    // what to show
    public var displayedTime: String {
        guard
            let end = end, //checks if they exist
            let start = start
        else { return "No fast started" }

        let diff = now.distance(to: end) - 0.99 //in seconds
        let total = now.distance(to: start) - 0.99 // -0.99 helps to adjust for precision
        
        if diff > 0 { //round up
            let secsLeft = Int(diff.rounded(.up)) // only show the highest time
            let hours = secsLeft / 3600
            let minutes = (secsLeft % 3600) / 60
            let seconds = secsLeft % 60
            
            //format time diff as HH:MM:SS
            return String(format: "%02d:%02d:%02d\nremaining", hours, minutes, seconds)
        }
        else if diff > -1 { // the instant second when the fast is complete, at neither time deficit or surplus
            let secsOver = Int((-diff).rounded(.down))
            let hours = secsOver / 3600
            let minutes = (secsOver % 3600) / 60
            let seconds = secsOver % 60
            
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        else { //round down
            let secsOver = Int((-diff).rounded(.down))
            let hours = secsOver / 3600
            let minutes = (secsOver % 3600) / 60
            let seconds = secsOver % 60
            
            let total = Int(abs(total).rounded(.down))
            let hours1 = total / 3600
            let minutes1 = (total % 3600) / 60
            let seconds1 = total % 60
            
            //format time diff as HH:MM:SS
            return String(format: "%02d:%02d:%02d\n(+%02d:%02d:%02d)", hours1, minutes1, seconds1, hours, minutes, seconds)
        }
    }

    // 1 to 5 based on (now–start)/(end–start)+1
    public var flowerStage: Int {
        guard let start = start, //checking they exist
              let end = end
        else {
            return 1 // default to stage 1 if no fast
        }

        let totalDuration = end.timeIntervalSince(start)
        let currentDuration = now.timeIntervalSince(start)

        // fraction of time completed, capped at 1 if we pass the end
        let fraction = max(0, min(1, currentDuration / totalDuration))

        //each 25% is a new stage from 1 to 4 and only shows 5 on full completion
        return min(Int((fraction * 4.0))+1, 5)
    }
}
