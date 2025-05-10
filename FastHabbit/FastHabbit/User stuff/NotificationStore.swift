//
//  NotificationStore.swift
//  FastHabbit
//
//  Created by Amy  on 28/04/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import UserNotifications
import UIKit

class NotificationStore: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    private var listener: ListenerRegistration?

    func startListening() { //need constant never ending notif updates
        guard let me = Auth.auth().currentUser?.uid else { return }
        listener = Firestore.firestore()
            .collection("users").document(me)
            .collection("notifications")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snap, _ in
                guard let snap = snap else { return }
                
                //handling the added documents
                for change in snap.documentChanges {
                    if change.type == .added {
                        let d = change.document.data()
                        guard
                            let from = d["fromUID"] as? String,
                            let msg  = d["message"] as? String
                        else { continue }
                        
                        //so we can get their username in the notif
                        FirestoreService.shared.fetchUsername(for: from) { name in
                            guard let fromName=name else { return }
                            self.triggerLocalNotification(msg, fromName, change.document.documentID)

                        }
                    }
                    // updates list
                    self.notifications = snap.documents.compactMap { doc in
                        let d = doc.data()
                        guard
                            let from = d["fromUID"] as? String,
                            let msg = d["message"] as? String,
                            let ts = d["timestamp"] as? Timestamp,
                            let read = d["read"] as? Bool
                        else { return nil }
                        return NotificationModel(
                            id: doc.documentID,
                            fromUID: from,
                            message: msg,
                            timestamp: ts.dateValue(),
                            read: read
                        )
                    }
                    
                }
            }
    }

    func stopListening() { //ideally this would never be called
        listener?.remove() //only keeping for safety sake
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
        }
    }

    func triggerLocalNotification(_ msg: String, _ fromName: String, _ noteid: String) {
        // don’t schedule if the app is in the foreground
        guard UIApplication.shared.applicationState != .active else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "\(fromName) says:"
        content.body  = msg
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1, repeats: false
        )
        
        let req = UNNotificationRequest(
            identifier: noteid, //noteid = unique so the notifs will stack
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(req) { error in
            if let err = error {
                print("Local notif error:", err)
            }
        }
    }
    
}
