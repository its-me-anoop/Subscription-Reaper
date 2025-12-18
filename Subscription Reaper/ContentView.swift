//
//  ContentView.swift
//  Subscription Reaper
//
//  Created by Anoop Jose on 17/12/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subscription.nextBillingDate) private var subscriptions: [Subscription]
    @State private var subscriptionToEdit: Subscription?
    @State private var selectedTab = 0
    @State private var showingSettings = false

    var upcomingSubscriptions: [Subscription] {
        Array(subscriptions.prefix(4))
    }

    var totalMonthlyCost: Double {
        subscriptions.reduce(0) { total, sub in
            if sub.frequency == "Monthly" {
                return total + sub.amount
            } else {
                return total + (sub.amount / 12.0)
            }
        }
    }

    var commonCurrency: String {
        subscriptions.first?.currency ?? "USD"
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                dashboardView
                    .tag(0)
                    .toolbar(.hidden, for: .tabBar)
                
                NavigationStack {
                    SubscriptionsListView()
                }
                .tag(1)
                .toolbar(.hidden, for: .tabBar)
            }
            
            // Custom Navigation Bar
            customBottomBar
        }
        .sheet(item: $subscriptionToEdit) { subscription in
            AddSubscriptionView(subscriptionToEdit: subscription.name.isEmpty && subscription.amount == 0 ? nil : subscription)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private var customBottomBar: some View {
        HStack(spacing: 0) {
            // Main Tabs Group
            ZStack(alignment: .leading) {
                // Liquid Morphing Highlight
                Capsule()
                    .fill(.blue.opacity(0.15))
                    .frame(width: 80, height: 48)
                    .offset(x: CGFloat(selectedTab) * 85 + 6) // Adjust based on button width + spacing
                    .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0), value: selectedTab)
                
                HStack(spacing: 5) {
                    tabButton(title: "Dashboard", icon: "house.fill", index: 0)
                    tabButton(title: "List", icon: "list.bullet", index: 1)
                }
                .padding(6)
            }
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            Spacer()
            
            // Detached Floating Action Button
            Button(action: { 
                hapticFeedback(.medium)
                subscriptionToEdit = Subscription() 
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 58, height: 58)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private func tabButton(title: String, icon: String, index: Int) -> some View {
        Button(action: {
            if selectedTab != index {
                hapticFeedback(.light)
                withAnimation {
                    selectedTab = index
                }
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: selectedTab == index ? .bold : .regular))
                    .scaleEffect(selectedTab == index ? 1.1 : 1.0)
                Text(title)
                    .font(.system(size: 10, weight: selectedTab == index ? .bold : .medium))
            }
            .foregroundStyle(selectedTab == index ? .blue : .secondary)
            .frame(width: 80, height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    private var dashboardView: some View {
        NavigationStack {
            ZStack {
                AnimatedBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Dashboard Header
                        DashCardView(
                            amount: totalMonthlyCost,
                            currency: commonCurrency
                        )
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Subscriptions List
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Upcoming Renewals")
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                
                                Spacer()
                                
                                NavigationLink {
                                    SubscriptionsListView()
                                } label: {
                                    Text("See All")
                                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding(.horizontal)
                            
                            if subscriptions.isEmpty {
                                ContentUnavailableView(
                                    "No Subscriptions",
                                    systemImage: "creditcard.and.123",
                                    description: Text("Add your first subscription to track spending.")
                                )
                                .padding(.top, 40)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(upcomingSubscriptions) { subscription in
                                        SubscriptionRowView(subscription: subscription)
                                            .onTapGesture {
                                                subscriptionToEdit = subscription
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(greeting)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                    }
                }
            }
        }
    }

    private func deleteSubscriptions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let subscription = upcomingSubscriptions[index]
                modelContext.delete(subscription)
            }
        }
    }
}

// Helper button style for press effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
