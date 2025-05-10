//
//  fasting_tracker_testApp.swift
//  fasting tracker test
//
//  Created by Amy  on 02/02/2025.
//

//@main
//struct fasting_tracker_testApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

import SwiftUI
import FirebaseCore
import UserNotifications
import FirebasePerformance

@main
struct FastHabbitApp: App {
    @StateObject private var authModel = AuthModel()
    @StateObject private var timer = TimerModel()
//    @StateObject private var nStore = NotificationStore()
    
    init() {
        FirebaseApp.configure()
        Performance.sharedInstance().isDataCollectionEnabled = true
    }

    var body: some Scene {
        WindowGroup {
            FrontPageView()
                .environmentObject(authModel)
                .environmentObject(timer)
//                .environmentObject(nStore)
                .onAppear {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                        if let error = error {
                            print("Notification permission error:", error)
                        } else if granted {
                            print("Notifications granted?", granted)
                            DispatchQueue.main.async {
                                UIApplication.shared.registerForRemoteNotifications()
                            }
                        }
                    }
                }
        }
        
    }
}


