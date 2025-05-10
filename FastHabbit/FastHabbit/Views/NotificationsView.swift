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
    @EnvironmentObject private var store: NotificationStore

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
                            .frame(width:20)
                    }
                    .offset(x:140, y:-98)
                }
            }
        }
        .defaultScrollAnchor(.top)
    }
}

struct NotificationRow: View {
    let notification: NotificationModel
    @State private var fromName: String = "…"
    @EnvironmentObject private var store: NotificationStore

    init(_ n: NotificationModel) {
        self.notification = n
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(notification.message)
                    .font(.custom("Jua", size: 20))
                if !notification.read { //if the notif is unread
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                }
            }
            HStack {
                Text(notification.timestamp, style: .time)
                    .font(.caption2)
                Spacer()
                Text("From: \(fromName)")
                    .font(.custom("Jua", size: 12))
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
