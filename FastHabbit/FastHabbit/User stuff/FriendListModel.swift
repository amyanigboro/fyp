//
//  FriendListViewModel.swift
//  FastHabbit
//
//  Created by Amy  on 28/04/2025.
//


import Combine
import FirebaseFirestore
import FirebaseAuth

class FriendListModel: ObservableObject {
    @Published var friends: [String] = []
    @Published var incoming: [String] = []
    @Published var namesByUID: [String: String] = [:]

    private var listener: ListenerRegistration?

    func start() {
        guard let me = Auth.auth().currentUser?.uid else { return }
        listener = FirestoreService.shared.db
            .collection("users")
            .document(me)
            .addSnapshotListener { snap, _ in
                guard let d = snap?.data() else { return }
                self.friends = d["friends"]               as? [String] ?? []
                self.incoming = d["friendRequestsReceived"] as? [String] ?? []
                self.loadNames(for: self.friends + self.incoming)
            }
    }

    func stop() {
        listener?.remove()
    }

    private func loadNames(for uids: [String]) {
        for uid in uids where namesByUID[uid] == nil {
            FirestoreService.shared.fetchUsername(for: uid) { name in
                DispatchQueue.main.async {
                    self.namesByUID[uid] = name ?? uid.prefix(8) + "…"
                }
            }
        }
    }

    func sendRequest(to otherUID: String) {
        FirestoreService.shared.sendFriendRequest(to: otherUID) { _ in }
    }
    func accept(_ uid: String) {
        FirestoreService.shared.acceptFriendRequest(from: uid) { _ in }
    }
    func decline(_ uid: String) {
        FirestoreService.shared.declineFriendRequest(from: uid) { _ in }
    }
    func remove(_ uid: String) {
        FirestoreService.shared.removeFriend(uid) { _ in }
    }
    
    func sendPing(_ uid: String) {
        let messages = [
          "You can do this!",
          "Keep going!",
          "We’re in this together!"
        ]
        let msg = messages.randomElement()!
        FirestoreService.shared.sendPing(to: uid, message: msg) {err in
            if let err = err {
                print("Ping failed:", err)
            } else {
                print("Ping sent!")
            }
        }
    }
}
