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
    @Query private var subscriptions: [Subscription]
    @State private var subscriptionToEdit: Subscription?

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

    var body: some View {
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
                            Text("Your Subscriptions")
                                .font(.system(.title3, design: .rounded, weight: .bold))
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
                                    ForEach(subscriptions) { subscription in
                                        HStack(spacing: 16) {
                                            // Icon Placeholder
                                            Image(systemName: subscription.icon)
                                                .font(.title2)
                                                .foregroundStyle(.blue)
                                                .frame(width: 44, height: 44)
                                                .background(.blue.opacity(0.1))
                                                .clipShape(Circle())
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(subscription.name)
                                                    .font(.system(.headline, design: .rounded))
                                                Text(subscription.nextBillingDate, format: .dateTime.month().day())
                                                    .font(.system(.subheadline, design: .rounded))
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Text(subscription.amount, format: .currency(code: subscription.currency))
                                                .font(.system(.headline, design: .rounded))
                                                .foregroundStyle(.primary)
                                        }
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            subscriptionToEdit = subscription
                                        }
                                    }
                                    .onDelete(perform: deleteSubscriptions)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { subscriptionToEdit = Subscription() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            .sheet(item: $subscriptionToEdit) { subscription in
                AddSubscriptionView(subscriptionToEdit: subscription.name.isEmpty && subscription.amount == 0 ? nil : subscription)
            }
        }
    }

    private func deleteSubscriptions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(subscriptions[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
