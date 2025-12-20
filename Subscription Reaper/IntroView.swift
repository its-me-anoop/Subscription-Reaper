//
//  IntroView.swift
//  Subscription Reaper
//
//  Created by Anoop Jose on 18/12/2025.
//

import SwiftUI

struct IntroSlide: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
}

struct IntroView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentTab = 0
    @Namespace private var introNamespace
    
    let slides = [
        IntroSlide(
            title: "Welcome to Subscription Reaper",
            subtitle: "Take control of your digital life and stop wasting money on forgotten subscriptions.",
            icon: "leaf.fill",
            tint: .green
        ),
        IntroSlide(
            title: "Smart Predictions",
            subtitle: "Our AI models automatically predict your next bill and identify potential savings.",
            icon: "sparkles",
            tint: .purple
        ),
        IntroSlide(
            title: "Budget with Ease",
            subtitle: "Set monthly limits and get visual alerts when you're approaching your budget.",
            icon: "chart.bar.fill",
            tint: .blue
        ),
        IntroSlide(
            title: "Ready to Reap?",
            subtitle: "Join thousands of others saving money every month with Subscription Reaper.",
            icon: "checkmark.seal.fill",
            tint: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    if currentTab < slides.count - 1 {
                        Button("Skip") {
                            withAnimation {
                                hasCompletedOnboarding = true
                            }
                        }
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding()
                    }
                }
                
                TabView(selection: $currentTab) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        SlideView(slide: slides[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Capsule()
                            .fill(currentTab == index ? slides[currentTab].tint : Color.primary.opacity(0.2))
                            .frame(width: currentTab == index ? 24 : 8, height: 8)
                    }
                }
                .padding(.bottom, 32)
                
                // Action Button
                Button(action: {
                    if currentTab < slides.count - 1 {
                        withAnimation {
                            currentTab += 1
                        }
                    } else {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }
                }) {
                    Text(currentTab == slides.count - 1 ? "Start Reaping" : "Continue")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            slides[currentTab].tint
                                .shadow(.inner(color: .white.opacity(0.3), radius: 1, x: 0, y: 1))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .padding(.horizontal, 32)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.bottom, 40)
            }
        }
    }
}

struct SlideView: View {
    let slide: IntroSlide
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(slide.tint.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)
                
                Image(systemName: slide.icon)
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(slide.tint)
                    .shadow(color: slide.tint.opacity(0.5), radius: 20, x: 0, y: 10)
            }
            .padding(.top, 40)
            
            VStack(spacing: 16) {
                Text(slide.title)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(slide.subtitle)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    IntroView()
}
