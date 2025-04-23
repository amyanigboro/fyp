//
//  FastFirestoreModel.swift
//  FastHabbit
//
//  Created by Amy  on 17/04/2025.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

struct FastFirestoreModel: Codable, Identifiable {
    let id: String
    let startDate: Date
    let endDate: Date
    let isComplete: Bool
    let flowerEarned: String
    let duration: Double
    let sethours: Double
}

extension FastFirestoreModel {
  // convenience initializer from Fast struct
    init(_ fast: Fast) {
        self.id          = fast.id
        self.startDate   = fast.startDate
        self.endDate     = fast.endDate
        self.isComplete  = fast.isComplete
        self.flowerEarned = fast.flowerEarned
        self.duration    = fast.duration
        self.sethours = fast.sethours
    }

    var dictionary: [String: Any] {
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

final class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private var uid: String {
        Auth.auth().currentUser!.uid
    }

    //save one fast under `/users/{uid}/fasts/{fast.id}`
    func save(_ fast: Fast, completion: ((Error?) -> Void)? = nil) {
        let model = FastFirestoreModel(fast)
        let path  = db
            .collection("users")
            .document(uid)
            .collection("fasts")
            .document(model.id)

        path.setData(model.dictionary) { err in
            completion?(err)
        }
    }
    //delete the fast in `/users/{uid}/fasts/{fast.id}`
    func delete(_ fast: Fast, completion: ((Error?) -> Void)? = nil) {
        let path  = db
            .collection("users")
            .document(uid)
            .collection("fasts")
            .document(fast.id)
        
        path.delete { err in
            completion?(err)
        }
    }

    //fetches all fasts for the current user and sorts by startDate descending
    func fetchAll(completion: @escaping ([Fast]) -> Void) {
        //checks if user is signed in
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        db
            .collection("users") // users
            .document(uid) // users/uid
            .collection("fasts") // users/uid/fasts
            .order(by: "startDate", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                let fasts: [Fast] = docs.compactMap { doc -> Fast? in
                    let data = doc.data()
                    guard
                        let id = data["id"] as? String,
                        let ts1 = data["startDate"] as? Timestamp,
                        let ts2 = data["endDate"]   as? Timestamp,
                        let isC = data["isComplete"] as? Bool,
                        let flower = data["flowerEarned"] as? String,
                        let dur = data["duration"] as? Double,
                        let set = data["sethours"] as? Double
                    else { return nil }
                    
                    var fast = Fast(
                        id: id,
                        startDate: ts1.dateValue(),
                        endDate: ts2.dateValue(),
                        isComplete: isC,
                        flowerEarned: flower,
                        duration:  dur,
                        sethours: set
                    )
                    fast.adjustEndDate(ts2.dateValue())  // recalculate duration
                    fast.adjustStartDate(ts1.dateValue())
                    return fast
                }
                completion(fasts)
            
            }
    }
    
    // listens for updates in the fast collection
    func observeAll(completion: @escaping ([Fast]) -> Void) -> ListenerRegistration? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        
        return db
            .collection("users").document(uid)
            .collection("fasts")
            .order(by: "startDate", descending: true)
            .addSnapshotListener { snapshot, _ in
                let loaded: [Fast] = snapshot?.documents.compactMap { doc in
                    let d = doc.data()
                    guard
                        let id = d["id"] as? String,
                        let ts1 = d["startDate"] as? Timestamp,
                        let ts2 = d["endDate"] as? Timestamp,
                        let isC = d["isComplete"] as? Bool,
                        let flower = d["flowerEarned"] as? String,
                        let dur = d["duration"] as? Double,
                        let set = d["sethours"] as? Double
                    else { return nil }
                    return Fast(
                        id: id,
                        startDate: ts1.dateValue(),
                        endDate: ts2.dateValue(),
                        isComplete: isC,
                        flowerEarned: flower,
                        duration: dur,
                        sethours: set
                    )
                } ?? []
            completion(loaded)
        }
    }

}
