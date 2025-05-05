//
//  NotificationStore.swift
//  FastHabbit
//
//  Created by Amy  on 28/04/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class NotificationStore: ObservableObject {
  @Published var notifications: [NotificationModel] = []
  private var listener: ListenerRegistration?

    func startListening() {
        guard let me = Auth.auth().currentUser?.uid else { return }
        listener = Firestore.firestore()
            .collection("users").document(me)
            .collection("notifications")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snap, _ in
            self.notifications = snap?.documents.compactMap { doc in
                let d = doc.data()
                guard let from = d["fromUID"] as? String,
                    let msg  = d["message"] as? String,
                    let ts   = d["timestamp"] as? Timestamp,
                    let read = d["read"] as? Bool
                else { return nil }
                return NotificationModel(
                    id: doc.documentID,
                    fromUID: from,
                    message: msg,
                    timestamp: ts.dateValue(),
                    read: read
                )
            } ?? []
        }
    }

    func stopListening() {
        listener?.remove()
    }
    
    func delete(_ noti: NotificationModel) {
        FirestoreService.shared.deleteNotification(noti.id) { err in
            if let err = err { print("Delete failed:", err) }
            else {
                DispatchQueue.main.async {
                    self.notifications.removeAll { $0.id == noti.id }
                }
            }
        }
    }
    
    func read(_ noti: NotificationModel) {
        FirestoreService.shared.readNotification(noti.id) { err in
            if let err = err { print("Read failed:", err) }
            else {
                print("read successful")
            }
        }
    }

}
