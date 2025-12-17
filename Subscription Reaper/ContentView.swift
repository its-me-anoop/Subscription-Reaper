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
    @Query private var items: [Item]

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
                            
                            if items.isEmpty {
                                ContentUnavailableView(
                                    "No Subscriptions",
                                    systemImage: "creditcard.and.123",
                                    description: Text("Add your first subscription to track spending.")
                                )
                                .padding(.top, 40)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(items) { item in
                                        HStack {
                                            Text("Subscription")
                                                .font(.system(.headline, design: .rounded))
                                            Spacer()
                                            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .shortened))
                                                .font(.system(.subheadline, design: .rounded))
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                    .onDelete(perform: deleteItems)
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
                    Button(action: addItem) {
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

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
