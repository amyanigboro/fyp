//
//  NotificationsView.swift
//  FastHabbit
//
//  Created by Amy  on 27/04/2025.
//


import SwiftUI
import FirebaseFirestore
import SwiftUIIntrospect

struct NotificationsView: View {
    @StateObject private var store = NotificationStore()

    var body: some View {
        ScrollView {
            if store.notifications.isEmpty {
                    Text("No notifications")
            } else {
                ForEach(store.notifications) { n in //each notif
                    NotificationRow(n)
                        .environmentObject(store)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            store.read(n) //tap to read it
                        }
                    Button(role: .destructive) {
                        store.delete(n)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width:50)
                            .offset(x:140, y:-90)
                    }
                }
            }
        }
        .defaultScrollAnchor(.top)
        .onAppear {
            store.startListening() //get the notifs
        }
        .onDisappear {
            store.stopListening() //dont get the notifs
        }
    }
}

struct NotificationRow: View {
    let notification: NotificationModel
    @State private var fromName: String = "…"
    @EnvironmentObject private var store: NotificationStore  // if you want to mark read

    init(_ n: NotificationModel) {
        self.notification = n
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(notification.message)
                .font(.headline)
            HStack {
                Text(notification.timestamp, style: .time)
                    .font(.caption2)
                Spacer()
                Text("From: \(fromName)")
                    .font(.caption)
                if !notification.read { //if the notif is unread
                    Circle()
                        .fill(.blue)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .foregroundColor(.darkgreen)
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .frame(width: 300)
        .onAppear {
          //fetch the username
            FirestoreService.shared.fetchUsername(for: notification.fromUID) { name in
                fromName = name ?? notification.fromUID
            }
        }
    }
}
