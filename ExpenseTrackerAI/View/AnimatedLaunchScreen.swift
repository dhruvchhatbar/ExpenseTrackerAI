//
//  AnimatedLaunchScreen.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 20/09/25.
//

import SwiftUI

struct AnimatedLaunchScreen: View {
    var onFinished: (() -> Void)? = nil
    @State private var isAnimating = false
    @State private var showAppName = false
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    @State private var topColor: Color = .white
    @State private var bottomColor: Color = .white
    @State private var nameOpacity: Double = 0
    @State private var nameOffsetY: CGFloat = -50
    @State private var dotsActive = false
    private let baseIconSize: CGFloat = 200
    
    
    var body: some View {
        ZStack {
            // Background gradient matching app theme
            
            LinearGradient(
                colors: [
                    topColor,
                    bottomColor
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Animated App Icon
                Image("splashIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: baseIconSize, height: baseIconSize)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .opacity(opacity)
                    .shadow(color: Color.orange.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // App Name with Animation
                VStack(spacing: 8) {
                    Text("Expense AI")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(nameOpacity)
                        .offset(y: nameOffsetY)
                    
                    Text("Smart Expense Tracking")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .opacity(nameOpacity)
                        .offset(y: nameOffsetY)
                }
                
                // Loading indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.white.opacity(0.75))
                            .frame(width: 8, height: 8)
                            .scaleEffect(dotsActive ? 1.15 : 0.85)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.18),
                                value: dotsActive
                            )
                    }
                }
                .opacity(nameOpacity)
            }
        }
        .onAppear {
            // Set theme colors
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // 0s: Icon visible and static. Fade/slide in name after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.6)) {
                topColor = Color(red: 1.0, green: 0.722, blue: 0.271)
                bottomColor = Color(red: 1.0, green: 0.97, blue: 0.93)
                nameOpacity = 1
                nameOffsetY = 0
            }
            dotsActive = true
        }
        
        // 2s: Shrink briefly, then scale big, then navigate
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let shrinkDuration = 0.18
            withAnimation(.easeIn(duration: shrinkDuration)) {
                scale = 0.8
            }
            let expandDelay = shrinkDuration + 0.02
            DispatchQueue.main.asyncAfter(deadline: .now() + expandDelay) {
                let expandDuration = 1.0
                withAnimation(.spring(response: expandDuration, dampingFraction: 0.55, blendDuration: 0.25)) {
                    nameOpacity = 0
                    scale = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    onFinished?()
                }
            }
        }
    }
}

struct AnimatedLaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedLaunchScreen()
    }
}
