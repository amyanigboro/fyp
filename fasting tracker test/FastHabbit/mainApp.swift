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


@main
struct fasting_tracker_testApp: App {
    @StateObject private var authModel = AuthModel()
    @StateObject private var timer = TimerModel()
    @StateObject private var fastStore = FastStore()


    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            FrontPageView()
                .environmentObject(authModel)
                .environmentObject(timer)
                .environmentObject(fastStore)
                .onAppear {
                    fastStore.startListening()
                }
        }
    }
}
