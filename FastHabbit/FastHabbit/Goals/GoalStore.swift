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

    private var fastarray: [Fast] = []
    private var goalsListener: ListenerRegistration?
    private var fastsCancellable: AnyCancellable?

    init() {
        FastStore.shared.startListening()
        // recompute whenever new fasts array is published
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
            //if the goal is already complete then stop recompting
            guard goal.completedAt == nil else { return goal }
            
            var g = goal
            g.progress = self.calculateProgress(for: g, in: allFasts)
            if g.progress >= g.targetCount {
                g.completedAt = Date()
            }
            return g
        }
        active = withProgress.filter { !$0.isComplete } //incomplete goals
        complete = withProgress.filter { $0.isComplete } //complete goals
    }

    private func calculateProgress(for goal: Goal, in fasts: [Fast]) -> Int {
        
//        guard goal.completedAt == nil else { return goal.progress }
        
        //apply the right filter for each goal type then count
        switch goal.type {
            case .countByFlower:
                return fasts.filter { $0.flowerEarned == goal.filterValue && $0.isComplete }.count
            case .countByDuration:
                //has to exist first of course
                guard let hrs = Double(goal.filterValue) else { return 0 }
                return fasts.filter { $0.duration >= hrs * 3600 && $0.isComplete }.count //converted to hours
            case .countInPeriod:
                return fasts.filter {
                    $0.isComplete &&
                    $0.startDate >= goal.startDate && //start dates are on or after the goal start date
                    (goal.endDate == nil || $0.startDate <= goal.endDate!) //no end date or the start date is before or equal to the end date
                }.count
        }
    }
}

//for testing
#if DEBUG
extension GoalStore {
  //so can use calculateProgress for unit tests
  func _test_calculateProgress(for goal: Goal, in fasts: [Fast]) -> Int {
    return calculateProgress(for: goal, in: fasts)
  }
}
#endif
