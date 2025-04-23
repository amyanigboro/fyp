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
    
    //for the custom input
//    @State private var customHoursInput = ""       // “16.5” etc.
//    @State private var customHoursValue: Double = 16
//    @State private var showingCustomInput = false
    
    @State private var customHoursInput = ""      // raw text
    @State private var customHours: Double = 0    // parsed value
    @State private var showCustomPrompt = false

    // refresh view every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Image("Gardenbg")
                .resizable()
//                .scaledToFit()
                .frame(width: 400, height: 700)
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
                        Text("Custom (\(Int(customHours)))").tag(fastlength.custom)
                    }
                    .pickerStyle(MenuPickerStyle())
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
                
//                .sheet(isPresented: $showingCustomInput) {
//                      VStack(spacing: 20) {
//                        Text("Enter custom hours")
//                          .font(.headline)
//
//                        TextField("Hours", text: $customHoursInput)
//                          .keyboardType(.decimalPad)
//                          .textFieldStyle(.roundedBorder)
//                          .padding()
//
//                        HStack {
//                          Button("Cancel") {
//                            // fall back to 16h if they cancel
//                            selectedHours = .sixteen
//                            showingCustomInput = false
//                          }
//                          Spacer()
//                          Button("OK") {
//                            if let v = Double(customHoursInput), v > 0 {
//                              customHoursValue = v
//                            }
//                            showingCustomInput = false
//                          }
//                        }
//                        .padding(.horizontal)
//                      }
//                      .padding()
//                    }
                // MARK: — the pop‑up to enter custom hours
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
                
            }
//            .padding()
//            .padding(.horizontal, 30)
        }
    }

    // remaining if not done, overtime if done
    private var displayedTime: String {
        guard let endTime = endTime else { return "No fast started" }
        
        let diff = currentTime.distance(to: endTime)

        let absDiff = abs(diff)
        let hours = Int(absDiff) / 3600
        let minutes = Int(absDiff) / 60 % 60
        let seconds = Int(absDiff) % 60

        //format time diff as HH:MM:SS
        let formatted = String(format: "%02d:%02d:%02d", hours, minutes, seconds)

        if diff > 0 {
            return "\(formatted) remaining"
        } else {
            return "+\(formatted) overtime"
        }
    }

    //shows stage 1 to 5 of the flower based on fast progress
    private var flowerStageImageName: String {
        guard let startTime = startTime,
              let endTime = endTime else {
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

    //starts the fast timer
    private func startFast() {
        startTime = currentTime
        endTime = startTime!.addingTimeInterval(Double(hoursToFast) * 3600)
        isActive = true
    }

    //resets the timer
    private func resetTimer() {
        startTime = nil
        endTime = nil
        isActive = false
    }
    
    //stops the timer and store fast length in the database
    @State private var isComplete: Bool = false
    
    //calculates the current duration of the fast
    private func currentFastDuration() -> Double {
        return Double(currentTime.distance(to: startTime!))
    }
    
    private func calcFastCompletion() -> Bool {
        guard let endTime = endTime else { return false }
        let duration = endTime.distance(to: startTime!)
        if duration>=hoursToFast {
            return true
        }
        else {
            return false
        }
    }
    
    private func stopFast() {
        guard isActive else { return }
        isActive = false
        
        let newFast = Fast(
            id: UUID().uuidString,
            startDate: startTime!,
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
        
        startTime = nil
        endTime = nil
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
