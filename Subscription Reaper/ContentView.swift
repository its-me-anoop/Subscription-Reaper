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
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("isBudgetEnabled") private var isBudgetEnabled = false
    @AppStorage("monthlyBudget") private var monthlyBudget: Double = 50.0
    private var currencyService = CurrencyService.shared

    var upcomingSubscriptions: [Subscription] {
        Array(subscriptions.prefix(4))
    }

    var totalMonthlyCost: Double {
        subscriptions.reduce(0) { total, sub in
            let monthlyAmount = sub.frequency == "Monthly" ? sub.amount : (sub.amount / 12.0)
            let convertedAmount = currencyService.convert(monthlyAmount, from: sub.currency, to: defaultCurrency)
            return total + convertedAmount
        }
    }

    var dashboardTint: Color {
        guard isBudgetEnabled && monthlyBudget > 0 else { return .blue }
        
        let percent = totalMonthlyCost / monthlyBudget
        if percent > 1.0 {
            return .red
        } else if percent > 0.75 {
            return .orange
        } else {
            return .blue
        }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    @State private var searchText = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "house.fill", value: 0) {
                dashboardView
            }
            
            Tab("List", systemImage: "list.bullet", value: 1) {
                NavigationStack {
                    SubscriptionsListView()
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                addButton
                            }
                        }
                }
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 2) {
                NavigationStack {
                    SettingsView()
                }
            }

            Tab("Search", systemImage: "magnifyingglass", value: 3, role: .search) {
                NavigationStack {
                    SubscriptionsListView(searchText: $searchText)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                addButton
                            }
                        }
                }
            }
        }
        .searchable(text: $searchText)
        .sheet(item: $subscriptionToEdit) { subscription in
            AddSubscriptionView(subscriptionToEdit: subscription.name.isEmpty && subscription.amount == 0 ? nil : subscription)
        }
    }

    private var addButton: some View {
        Button(action: {
            hapticFeedback(.medium)
            subscriptionToEdit = Subscription()
        }) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.blue)
                .padding(8)
                .background {
                    Circle()
                        .fill(.blue.opacity(0.1))
                        .conditionalGlassEffect(cornerRadius: 20)
                }
                .overlay {
                    Circle()
                        .stroke(.blue.opacity(0.2), lineWidth: 0.5)
                }
        }
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
                            currency: defaultCurrency,
                            tint: dashboardTint
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
                    addButton
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

// MARK: - Extension for Glass Effect
extension View {
    @ViewBuilder
    func conditionalGlassEffect(cornerRadius: CGFloat = 24) -> some View {
        if #available(iOS 18.0, *) {
            self.glassEffect(.clear.tint(.white.opacity(0.1)).interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            self
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
