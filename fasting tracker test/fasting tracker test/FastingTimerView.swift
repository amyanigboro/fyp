//
//  FastingTimerView.swift
//  FastHabbit
//
//  Created by Amy  on 14/03/2025.
//


import SwiftUI

struct FastingTimerView: View {
    @State private var selectedHours: fastlength = .sixteen
    @State private var selectedFlower = "Red"
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var currentTime = Date.now
    @State private var isActive = false

    // refresh view every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Image("Gardenbg")
                .resizable()
//                .scaledToFit()
                .frame(width: 430, height: 700)
                .padding(.bottom, 50)
            
            VStack(spacing: 20) {
                // timer display
                Text(displayedTime)
                    .onReceive(timer) { _ in //update every second
                        currentTime = Date.now
                    }
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .offset(y: 50)
                    .padding(.bottom, 100)
                
                // flower image
                if (!isActive) {
                    Image("dirt")
                        .resizable()
                        .scaledToFit()
                        .offset(y:90)
                        .frame(width: 200, height: 200)
                } else {
                    Image(flowerStageImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                // buttons to pick fast length & flower
                VStack {
                    // preset hours
                    Picker("Hours", selection: $selectedHours) {
                        Text("13").tag(fastlength.thirteen)
                        Text("16").tag(fastlength.sixteen)
                        Text("18").tag(fastlength.eighteen)
                        Text("Custom").tag(fastlength.custom)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Menu {
                        Button("Red") {
                            selectedFlower = "Red"
                        }
                        Button("Pink") {
                            selectedFlower = "Pink"
                        }
                        Button("Blue") {
                            selectedFlower = "Blue"
                        }
                        Button("Orange") {
                            selectedFlower = "Orange"
                        }
                        Button("Purple") {
                            selectedFlower = "Purple"
                        }
                    } label: {
                        Label("Choose Flower", systemImage: "leaf.fill")
                            .frame(width: 200, height:50)
                            .background(.accent)
                            .tint(.darkgreen)
                            .cornerRadius(10)
                        
                    }
                    
                }
                .padding()
                
                // 4) Start & Reset Buttons
                VStack(spacing: 20) {
                    HStack(spacing: 30) {
                        Button("Start Fast") {
                            startFast()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Stop Timer") {
                            stopFast()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Button("Reset Timer") {
                        resetTimer()
                    }
                    .buttonStyle(.bordered)
                    
                }
                .tint(.darkgreen)
                
                Spacer()
                
                // placeholder to see logs or add retrospective fasts
                //            NavigationLink("View Past Fasts") {
                //                PastFastsView()
                //            }
            }
            .padding()
            .padding(.horizontal, 30)
        }
    }

    // MARK: - Computed Properties

    /// Shows "HH:MM:SS remaining" if not done, or "+HH:MM:SS overtime" if done
    private var displayedTime: String {
        guard let endTime = endTime else { return "No fast started" }
        
        let diff = currentTime.distance(to: endTime)

        let absDiff = abs(diff)
        let hours = Int(absDiff) / 3600
        let minutes = Int(absDiff) / 60 % 60
        let seconds = Int(absDiff) % 60

        // Format as HH:MM:SS
        let formatted = String(format: "%02d:%02d:%02d", hours, minutes, seconds)

        if diff > 0 {
            return "\(formatted) remaining"
        } else {
            return "+\(formatted) overtime"
        }
    }

    /// Determines which stage (0..4) of the flower is shown based on fast progress
    private var flowerStageImageName: String {
        guard let startTime = startTime,
              let endTime = endTime else {
            return "\(selectedFlower)1" // default to stage 1 if no fast
        }

        let totalDuration = endTime.timeIntervalSince(startTime)
        let currentDuration = Date().timeIntervalSince(startTime)

        // fraction of time completed [0..1], 1 if we pass endTime
        let fraction = max(0, min(1, currentDuration / totalDuration))

        //each 25% is a new stage: 1..4
        let stage = Int((fraction * 4.0))+1 // 1,2,3,4,5
        return "\(selectedFlower)\(min(stage, 5))"
    }

    // Start the fast timer
    private func startFast() {
        startTime = currentTime
        endTime = startTime!.addingTimeInterval(Double(selectedHours.hours) * 3600)
        isActive = true
    }

    // Reset the timer
    private func resetTimer() {
        startTime = nil
        endTime = nil
        isActive = false
    }
    
    //Stop the timer and store fast length in the database
    @State private var isComplete: Bool = false
    
    private func calcFastCompletion() -> Bool {
        guard let endTime = endTime else { return false }
        let duration = endTime.distance(to: startTime!)
        if duration>=selectedHours.hours {
            return true
        }
        else {
            return false
        }
    }
    
    private func stopFast() {
        guard isActive else { return }
        isActive = false
        isComplete = true
        
        let newFast = Fast(startDate: startTime!, endDate: Date.now, isComplete: calcFastCompletion(), flowerEarned: selectedFlower)
        
        //store fast
        UserDefaults.standard.set(try? JSONEncoder().encode(newFast), forKey: "fasts")
        
        startTime = nil
        endTime = nil
    }
    
    enum fastlength {
        case sixteen
        case eighteen
        case thirteen
        case custom
        
        var hours: Double {
            switch self {
            case .sixteen:
                return 16
            case .eighteen:
                return 18
            case .thirteen:
                return 13
            case .custom:
                //Change to return user input somehow
                return 1/60
                
            }
        }
    }
}

#Preview {
    FastingTimerView()
}
