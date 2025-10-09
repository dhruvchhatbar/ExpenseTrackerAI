//
//  ExpenseTrackerAIApp.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 14/09/25.
//

import SwiftUI
import FirebaseCore

@main
//struct ExpenseTrackerAIApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @StateObject var authVM = AuthViewModel()
//    
//    var body: some Scene {
//        WindowGroup {
////            AuthView()
////                .environmentObject(authVM)
////            OfflineTestView()
////            FirestoreTestView()
//            ExpensesListView()
//        }
//    }
//}
//@main
struct ExpenseTrackerApp: App {
    init() { FirebaseApp.configure() }

    var body: some Scene {
        WindowGroup {
            LaunchScreenCoordinator()
        }
    }
}
