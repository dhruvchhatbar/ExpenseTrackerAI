//
//  LaunchScreenCoordinator.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 20/09/25.
//

import SwiftUI

struct LaunchScreenCoordinator: View {
    @State private var showLaunchScreen = true
    @State private var showMainApp = false
    
    var body: some View {
        ZStack {
            if showLaunchScreen {
                AnimatedLaunchScreen {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showLaunchScreen = false
                    }
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showMainApp = true
                    }
                }
                    .transition(.opacity)
            }
            
            if showMainApp {
                ExpensesListView()
                    .transition(.opacity)
            }
        }
        .onAppear { }
    }
}

struct LaunchScreenCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenCoordinator()
    }
}
