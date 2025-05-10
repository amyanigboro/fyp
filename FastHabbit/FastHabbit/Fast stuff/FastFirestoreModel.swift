//
//  FastFirestoreModel.swift
//  FastHabbit
//
//  Created by Amy  on 17/04/2025.
//


import Foundation
import FirebaseFirestore

struct FastFirestoreModel: Codable, Identifiable {
    let id: String
    let startDate: Date
    let endDate: Date
    let isComplete: Bool
    let flowerEarned: String
    let duration: Double
    let sethours: Double
    
    init(_ fast: Fast) {
        self.id          = fast.id
        self.startDate   = fast.startDate
        self.endDate     = fast.endDate
        self.isComplete  = fast.isComplete
        self.flowerEarned = fast.flowerEarned
        self.duration    = fast.duration
        self.sethours = fast.sethours
    }

    var fastDict: [String: Any] {
        [
          "id": id,
          "startDate": Timestamp(date: startDate),
          "endDate":   Timestamp(date: endDate),
          "isComplete": isComplete,
          "flowerEarned": flowerEarned,
          "duration": duration,
          "sethours": sethours
        ]
    }
}

class FastStore: ObservableObject {
    static let shared = FastStore()
    @Published var fasts: [Fast] = []
    private var listener: ListenerRegistration?

    func startListening() {
        listener = FirestoreService.shared.observeAll { [weak self] loaded in
            self?.fasts = loaded
        }
    }
    
    func stopListening() {
        listener?.remove()
    }
}

