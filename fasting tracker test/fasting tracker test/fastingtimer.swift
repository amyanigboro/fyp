//
//  fastingtimer.swift
//  FastHabbit
//
//  Created by Amy  on 20/03/2025.
//

import SwiftUI

@Observable
class FastTimer {
    let flowerColor: String
    let fastlength : Int
    
    init(flowerColor: String, fastlength: Int) {
        self.flowerColor = flowerColor
        self.fastlength = fastlength
    }
    
    private var timer: Timer? = nil
    private var timeElapsed = 0
    
    private var isRunning = false
    private var remainingTime: Int {
        fastlength - timeElapsed
    }
    
    private var progress: CGFloat {
        CGFloat(timeElapsed) / CGFloat(fastlength)
    }
    
    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            if remainingTime > 0 {
                timeElapsed+=1
            } else {
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        guard isRunning else { return }
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private var playButtonDisabled: Bool {
        guard remainingTime>0, !isRunning else { return false }
        return true
    }
    
    
}

