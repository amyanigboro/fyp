final class FirestoreService {
    static let shared = FirestoreService()
    let db = Firestore.firestore()

    private var uid: String {
        Auth.auth().currentUser!.uid
    }

    //save one fast under /users/{uid}/fasts/{fast.id}
    func save(_ fast: Fast, completion: ((Error?) -> Void)? = nil) {
        let model = FastFirestoreModel(fast)
        let path  = db
            .collection("users")
            .document(uid)
            .collection("fasts")
            .document(model.id)

        path.setData(model.fastDict) { err in
            completion?(err)
        }
    }
    //delete the fast in /users/{uid}/fasts/{fast.id}
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
    
    //saves the goall in /users/{uid}/goals/{goal.id}
    func saveGoal(_ goal: Goal, completion: ((Error?) -> Void)? = nil) {
      let data = try! Firestore.Encoder().encode(goal)
      db.collection("users")
        .document(uid)
        .collection("goals")
        .document(goal.id)
        .setData(data, completion: completion)
    }
    
    func deleteGoal(_ goal: Goal, completion: ((Error?) -> Void)? = nil) {
        let me = Auth.auth().currentUser!.uid
        db.collection("users")
          .document(me)
          .collection("goals")
          .document(goal.id)
          .delete { err in completion?(err) }
    }


    //checks all the goals
    func observeGoals(_ callback: @escaping ([Goal]) -> Void) -> ListenerRegistration {
      db.collection("users")
        .document(uid)
        .collection("goals")
        .order(by: "createdAt", descending: true)
        .addSnapshotListener { snap, _ in
          let goals = snap?.documents.compactMap { try? $0.data(as: Goal.self) } ?? []
          callback(goals)
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
            .order(by: "startDate", descending: true) //most recent first
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
                        let ts2 = data["endDate"] as? Timestamp,
                        let isC = data["isComplete"] as? Bool,
                        let flower = data["flowerEarned"] as? String,
                        let dur = data["duration"] as? Double,
                        let set = data["sethours"] as? Double
                    else { return nil }
                    
                    //error handling: swap them if the user accidentally enters dates in the wrong order
                    let start = min(ts1.dateValue(), ts2.dateValue())
                    let end = max(ts1.dateValue(), ts2.dateValue())
                    
                    var fast = Fast(
                        id: id,
                        startDate: start,
                        endDate: end,
                        isComplete: isC,
                        flowerEarned: flower,
                        duration: dur,
                        sethours: set
                    )
                    fast.adjustEndDate(ts2.dateValue()) // recalculate duration
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
            .collection("users")
            .document(uid)
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
    // MARK: – User Profile

    func createUserProfile(uid: String, email: String, username: String, completion: ((Error?) -> Void)? = nil) {
        let data: [String:Any] = [
          "email": email,
          "username": username,
          "profileImageURL": "",
          "friends": [],
          "friendRequestsSent": [],
          "friendRequestsReceived": []
        ]
        db.collection("users").document(uid).setData(data, completion: completion)
    }

    func updateUsername(_ username: String, completion: ((Error?) -> Void)? = nil) {
        let uid = Auth.auth().currentUser!.uid
        db.collection("users").document(uid)
           .updateData(["username": username], completion: completion)
    }

    //fetch profile picture
    func updateProfileImageURL(_ url: String, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db
        .collection("users")
        .document(uid)
        .updateData(["profileImageURL": url]) { err in
            completion?(err)
        }
    }
    
    //fetch username
    func fetchUsername(for uid: String, completion: @escaping (String?) -> Void) {
        db.collection("users").document(uid).getDocument { snap, err in
            guard let data = snap?.data(),
            let name = data["username"] as? String else {
                completion(nil)
                return
            }
            completion(name)
        }
    }


    // MARK: – Friend requests

    func sendFriendRequest(to otherUID: String, completion: ((Error?) -> Void)? = nil) {
        let me = Auth.auth().currentUser!.uid
        let batch = db.batch()
        let meRef    = db.collection("users").document(me)
        let themRef  = db.collection("users").document(otherUID)
        batch.updateData(
            ["friendRequestsSent": FieldValue.arrayUnion([otherUID])],
            forDocument: meRef
        )
        batch.updateData(
            ["friendRequestsReceived": FieldValue.arrayUnion([me])],
            forDocument: themRef
        )
        batch.commit(completion: completion)
    }

    func acceptFriendRequest(from otherUID: String, completion: ((Error?) -> Void)? = nil) {
        let me = Auth.auth().currentUser!.uid
        let batch = db.batch()
        let meRef   = db.collection("users").document(me)
        let themRef = db.collection("users").document(otherUID)

        // remove from requests, add to friends
        batch.updateData(["friendRequestsReceived": FieldValue.arrayRemove([otherUID]),
                          "friends": FieldValue.arrayUnion([otherUID])],
                         forDocument: meRef)
        batch.updateData(["friendRequestsSent": FieldValue.arrayRemove([me]),
                          "friends": FieldValue.arrayUnion([me])],
                         forDocument: themRef)
        batch.commit(completion: completion)
    }

    func declineFriendRequest(from otherUID: String, completion: ((Error?) -> Void)? = nil) {
        let me = Auth.auth().currentUser!.uid
        let batch = db.batch()
        let meRef   = db.collection("users").document(me)
        let themRef = db.collection("users").document(otherUID)
        batch.updateData(["friendRequestsReceived": FieldValue.arrayRemove([otherUID])], forDocument: meRef)
        batch.updateData(["friendRequestsSent": FieldValue.arrayRemove([me])], forDocument: themRef)
        batch.commit(completion: completion)
    }
    
    // Remove an existing friend relationship both ways
    func removeFriend(_ otherUID: String, completion: ((Error?) -> Void)? = nil) {
        let me = Auth.auth().currentUser!.uid
        let batch = db.batch()
        let meRef   = db.collection("users").document(me)
        let themRef = db.collection("users").document(otherUID)
        batch.updateData(["friends": FieldValue.arrayRemove([otherUID])], forDocument: meRef)
        batch.updateData(["friends": FieldValue.arrayRemove([me])],      forDocument: themRef)
        batch.commit(completion: completion)
    }

    // ------- Notifications -------
    
    func sendPing(to otherUID: String, message: String,
                completion: ((Error?) -> Void)? = nil) {
        let me = Auth.auth().currentUser!.uid
        let noteRef = db.collection("users")
                        .document(otherUID)
                        .collection("notifications")
                        .document()
        let data: [String:Any] = [
          "fromUID": me,
          "message": message,
          "timestamp": Timestamp(date: Date()),
          "read": false
        ]
        noteRef.setData(data, completion: completion)
    }

    func fetchNotifications(completion: @escaping ([NotificationModel]) -> Void) {
    let uid = Auth.auth().currentUser!.uid
    db.collection("users")
      .document(uid)
      .collection("notifications")
      .order(by: "timestamp", descending: true)
      .getDocuments { snap, _ in
        let notes = snap?.documents.compactMap { doc -> NotificationModel? in
          let d = doc.data()
          guard let msg = d["message"] as? String,
                let ts  = d["timestamp"] as? Timestamp,
                let from = d["fromUID"] as? String else { return nil }
          return NotificationModel(id: doc.documentID,
                                   fromUID: from,
                                   message: msg,
                                   timestamp: ts.dateValue(),
                                   read: (d["read"] as? Bool) ?? false)
        } ?? []
        completion(notes)
      }
    }
    
    func readNotification(_ noteId: String, completion: ((Error?) -> Void)? = nil) {
//        let uid = Auth.auth().currentUser!.uid
//        let noteRef = db.collection("users")
//                        .document(uid)
//                        .collection("notifications")
//                        .document(noteId)
//        let data: [String:Any] = [
//          "read": true
//        ]
//        noteRef.setData(data, completion: completion)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).collection("notifications").document(noteId)
          .updateData(["read": true], completion: completion)
    }
    
    func deleteNotification(_ noteId: String, completion: ((Error?) -> Void)? = nil) {
        guard let me = Auth.auth().currentUser?.uid else { return }
        db
          .collection("users")
          .document(me)
          .collection("notifications")
          .document(noteId)
          .delete { err in
            completion?(err)
          }
    }
    

    
    func updateNotificationsEnabled(_ on: Bool, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid)
          .updateData(["notificationsEnabled": on], completion: completion)
    }

}
