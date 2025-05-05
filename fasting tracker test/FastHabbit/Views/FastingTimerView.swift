//
//  FastingTimerView.swift
//  FastHabbit
//
//  Created by Amy  on 14/03/2025.
//


import SwiftUI

struct FastingTimerView: View {
    @StateObject private var fastwatch = FastStore()
    @StateObject private var timer = TimerModel()

    @State private var selectedHours: fastlength = .sixteen
    @State private var selectedFlower = "Red"
//    @State private var startTime: Date?
//    @State private var endTime: Date?
    @State private var currentTime = Date()
//    @State private var isActive = false
    
    //for the custom input
//    @State private var customHoursInput = ""       // “16.5” etc.
//    @State private var customHoursValue: Double = 16
//    @State private var showingCustomInput = false
    
    @State private var customHoursInput = ""      // raw text
    @State private var customHours: Double = 0    // parsed value
    @State private var showCustomPrompt = false

    // refresh view every second
    let fasttimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Image("Gardenbg")
                .resizable()
//                .scaledToFit()
                .frame(width: 400, height: 650)
//                .padding(.bottom, 50)
            
            VStack(spacing: 20) {
                // timer display
                Text(displayedTime)
                    .multilineTextAlignment(.center)
                    .onReceive(fasttimer) { _ in //update every second
                        currentTime = Date()
                    }
                    .font(.custom("Jua", size: 40))
                    .bold()
                    .foregroundColor(.white)
                    .offset(y: 100)
                    .padding(.bottom, 100)
                
                // flower image
                if (!timer.isActive) {
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
//                        Text("Custom (\(Int(hoursToFast)))").tag(fastlength.custom)
                            
                    }
                    .frame(maxWidth:300)
                    .pickerStyle(.segmented)
                    .onChange(of: selectedHours) {
                        if selectedHours == .custom {
                            showCustomPrompt = true
                        }
                    }
                    
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
                
                // the pop‑up to enter custom hours
                .alert("Custom hours", isPresented: $showCustomPrompt) {
                  TextField("Hours", text: $customHoursInput)
                    .keyboardType(.decimalPad)
                  Button("OK") {
                    // parse it, default to 0 if invalid
                    customHours = Double(customHoursInput) ?? 0
                  }
                } message: {
                  Text("Enter the number of hours you want to fast:")
                }
                
                // 4) Start & Reset Buttons
                VStack(spacing: 20) {
                    HStack(spacing: 30) {
                        Button("Start Fast") {
                            timer.startFast(hours: hoursToFast)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Stop Timer") {
                            stopFast()
                            
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Button("Reset Timer") {
                        timer.reset()
                    }
                    .buttonStyle(.bordered)
                    
                }
                .tint(.darkgreen)
                
                Spacer()
                
            }
        }
        .onAppear {
            fastwatch.startListening()
        }
    }
    

    // remaining if not done, overtime if done
    private var displayedTime: String {
        guard
            let endTime = timer.endTime,
            let startTime = timer.startTime
        else { return "No fast started" }
        
        let diff = currentTime.distance(to: endTime) - 0.99 //in seconds
        let total = currentTime.distance(to: startTime) - 0.99

//        let absDiff = abs(diff)
//        let hours = Int(absDiff) / 3600 //seconds /60 = minutes, minutes/60 = hours
//        let minutes = Int(absDiff) / 60 % 60
//        let seconds = Int(absDiff) % 60

        if diff > 0 { //round up
            let secsLeft = Int(diff.rounded(.up))
            let hours = secsLeft / 3600
            let minutes = (secsLeft % 3600) / 60
            let seconds = secsLeft % 60
            
            //format time diff as HH:MM:SS
            return String(format: "%02d:%02d:%02d\nremaining", hours, minutes, seconds)
        }
        else if diff > -1 {
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
        
//        let formatted = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
//
//        if diff >= 1 {
//            return "\(formatted) remaining"
//        } else if diff > -1 {
//            return "\(formatted)"
//        } else {
//            return "\(formatted) overtime"
//        }
    }

    //shows stage 1 to 5 of the flower based on fast progress
    private var flowerStageImageName: String {
        guard let startTime = timer.startTime,
              let endTime = timer.endTime else {
            return "\(selectedFlower)1" // default to stage 1 if no fast
        }

        let totalDuration = endTime.timeIntervalSince(startTime)
        let currentDuration = Date().timeIntervalSince(startTime)

        // fraction of time completed, capped at 1 if we pass endTime
        let fraction = max(0, min(1, currentDuration / totalDuration))

        //each 25% is a new stage: 1..4
        let stage = Int((fraction * 4.0))+1
        return "\(selectedFlower)\(min(stage, 5))"
    }

    //stops the timer and store fast length in the database
    @State private var isComplete: Bool = false
    
    //calculates the current duration of the fast
    private func currentFastDuration() -> Double {
        return Double(currentTime.distance(to: timer.startTime!))
    }
    
    private func calcFastCompletion() -> Bool {
        guard let endTime = timer.endTime else { return false }
        let duration = endTime.distance(to: timer.startTime!)
        if duration>=hoursToFast {
            return true
        }
        else {
            return false
        }
    }
    
    private func stopFast() {
        guard timer.isActive else { return }
        let newFast = Fast(
            id: UUID().uuidString,
            startDate: timer.startTime!,
            endDate: Date.now,
            isComplete: calcFastCompletion(),
            flowerEarned: selectedFlower,
            duration: currentFastDuration(),
            sethours: hoursToFast
        )
        
        //store fast in Firestore
        FirestoreService.shared.save(newFast) { err in
            if let err = err {
                print("Firestore save failed:", err)
            } else {
                print("Firestore save successful")
            }
        }
        
        timer.reset()
    }
    
    private var hoursToFast: Double {
      switch selectedHours {
      case .thirteen:  return 13
      case .sixteen:   return 16
      case .eighteen:  return 18
      case .custom:    return customHours
      }
    }

}

enum fastlength {
    case sixteen, eighteen, thirteen, custom
}



#Preview {
    FastingTimerView()
}
