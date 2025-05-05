//
//  GoalStore.swift
//  FastHabbit
//
//  Created by Amy  on 29/04/2025.
//

import Combine
import FirebaseFirestore

class GoalStore: ObservableObject {
    @Published var active:   [Goal] = []
    @Published var complete: [Goal] = []
    private var goals: [Goal] = []

    private var goalsListener: ListenerRegistration?
    private var fastsCancellable: AnyCancellable?

    init() {
        FastStore.shared.startListening()
        // whenever the FastStore publishes a new fasts array, recompute
        fastsCancellable = FastStore.shared.$fasts
            .sink { [weak self] _ in self?.recompute() }
    }

    func start() {
        goalsListener = FirestoreService.shared.observeGoals { [weak self] loaded in
            self?.goals = loaded
            self?.recompute()
        }
    }

    func stop() {
        goalsListener?.remove()
    }
    
    private func recompute() {
        let allFasts = FastStore.shared.fasts
        let withProgress = goals.map { goal -> Goal in
            var g = goal
            g.progress = self.calculateProgress(for: g, in: allFasts)
            return g
        }
        active   = withProgress.filter { !$0.isComplete }
        complete = withProgress.filter { $0.isComplete }
    }

    private func calculateProgress(for goal: Goal, in fasts: [Fast]) -> Int {
        // pull from fasts and apply the right filter:
        switch goal.type {
            case .countByFlower:
                return fasts.filter { $0.flowerEarned == goal.filterValue && $0.isComplete }.count
            case .countByDuration:
                guard let hrs = Double(goal.filterValue) else { return 0 }
                return fasts.filter { $0.duration >= hrs * 3600 && $0.isComplete }.count
            case .countInPeriod:
                return fasts.filter {
                    $0.isComplete &&
                    $0.startDate >= goal.startDate && //start dates are on or after the goal start date
                    (goal.endDate == nil || $0.startDate <= goal.endDate!) //no end date or the start date is before or equal to the end date
                }.count
        }
    }
}
