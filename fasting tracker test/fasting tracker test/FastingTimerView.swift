import SwiftUI

struct FastingTimerView: View {
    // MARK: - State
    @State private var selectedHours = 16
    @State private var selectedFlower = "red" // or an enum if you prefer
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var isActive = false

    // This timer publishes an event every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            // 1) Timer display
            Text(displayedTime)
                .font(.largeTitle)
                .bold()

            // 2) Flower image (show stage 0..4)
            Image(flowerStageImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            // 3) Buttons to pick fast length & flower
            HStack {
                // Example: pick a few preset hours
                Picker("Hours", selection: $selectedHours) {
                    Text("13").tag(13)
                    Text("16").tag(16)
                    Text("18").tag(18)
                    Text("Custom").tag(0) // handle custom in your code
                }
                .pickerStyle(SegmentedPickerStyle())

                // Flower choice
                Picker("Flower", selection: $selectedFlower) {
                    Text("Red").tag("red")
                    Text("Pink").tag("pink")
                    Text("Purple").tag("purple")
                    Text("Blue").tag("blue")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding()

            // 4) Start & Reset Buttons
            HStack(spacing: 40) {
                Button("Start Fast") {
                    startFast()
                }
                .buttonStyle(.borderedProminent)

                Button("Reset Timer") {
                    resetTimer()
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            // 5) A placeholder to navigate to logs or add retrospective fasts
            NavigationLink("View Past Fasts") {
                PastFastsView()
            }
        }
        .padding()
        // 6) Update timer every second
        .onReceive(timer) { _ in
            // Force SwiftUI to re-render if the timer is active
            if isActive {
                _ = displayedTime // Just reading it triggers a re-render
            }
        }
    }

    // MARK: - Computed Properties

    /// Shows "HH:MM:SS remaining" if not done, or "+HH:MM:SS overtime" if done
    private var displayedTime: String {
        guard let endTime = endTime else { return "No fast started" }
        let now = Date()
        let diff = endTime.timeIntervalSince(now)

        let absDiff = abs(diff)
        let hours = Int(absDiff) / 3600
        let minutes = Int(absDiff) / 60 % 60
        let seconds = Int(absDiff) % 60

        // Format as HH:MM:SS
        let formatted = String(format: "%02dh:%02dm:%02ds", hours, minutes, seconds)

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
            return "\(selectedFlower)_0" // default to stage 0 if no fast
        }

        let totalDuration = endTime.timeIntervalSince(startTime)
        let currentDuration = Date().timeIntervalSince(startTime)

        // fraction of time completed [0..1], clamp to 1 if we pass endTime
        let fraction = max(0, min(1, currentDuration / totalDuration))

        // Each 20% is a new stage: 0..4
        let stage = Int(fraction * 5.0) // 0,1,2,3,4
        return "\(selectedFlower)_\(min(stage, 4))"
    }

    // MARK: - Methods

    /// Starts a new fast using `selectedHours`.
    private func startFast() {
        let now = Date()
        startTime = now
        endTime = now.addingTimeInterval(Double(selectedHours) * 3600)
        isActive = true
    }

    /// Resets the timer, clearing all data
    private func resetTimer() {
        startTime = nil
        endTime = nil
        isActive = false
    }
}
