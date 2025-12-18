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

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Dashboard Header
                        DashCardView()
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
                    Button(action: addSubscription) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
        }
    }

    private func addSubscription() {
        withAnimation {
            let samples = [
                ("Netflix", 15.99, "tv.fill", Color.red),
                ("Spotify", 9.99, "music.note", Color.green),
                ("iCloud", 2.99, "cloud.fill", Color.blue),
                ("Adobe CC", 52.99, "photo.fill", Color.purple)
            ]
            let sample = samples.randomElement()!
            let newSubscription = Subscription(
                name: sample.0,
                amount: sample.1,
                icon: sample.2,
                nextBillingDate: Calendar.current.date(byAdding: .day, value: Int.random(in: 1...30), to: Date()) ?? Date()
            )
            modelContext.insert(newSubscription)
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
