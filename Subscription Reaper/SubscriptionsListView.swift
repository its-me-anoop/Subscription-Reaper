//
//  SubscriptionsListView.swift
//  Subscription Reaper
//
//  Created by Antigravity on 18/12/2025.
//

import SwiftUI
import SwiftData

struct SubscriptionsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subscription.nextBillingDate) private var subscriptions: [Subscription]
    
    @Binding var externalSearchText: String
    @State private var localSearchText = ""
    @State private var selectedCategory: String?
    @State private var subscriptionToEdit: Subscription?
    
    init(searchText: Binding<String>? = nil) {
        _externalSearchText = searchText ?? .constant("")
    }
    
    private var searchText: String {
        externalSearchText.isEmpty ? localSearchText : externalSearchText
    }
    
    let categories = ["All", "Entertainment", "Productivity", "Health", "Utilities", "Food", "Other"]
    
    var filteredSubscriptions: [Subscription] {
        subscriptions.filter { sub in
            let matchesSearch = searchText.isEmpty || sub.name.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || selectedCategory == "All" || sub.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView()
            
            VStack(spacing: 0) {
                // Category Filter Scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            CategoryTag(
                                title: category,
                                isSelected: (selectedCategory == category) || (category == "All" && selectedCategory == nil),
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCategory = category
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(.ultraThinMaterial.opacity(0.5))
                
                if filteredSubscriptions.isEmpty {
                    ContentUnavailableView(
                        "No Matches",
                        systemImage: "magnifyingglass",
                        description: Text("Try adjusting your search or filters.")
                    )
                    .padding(.top, 40)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredSubscriptions) { subscription in
                            NavigationLink {
                                SubscriptionDetailView(subscription: subscription)
                            } label: {
                                SubscriptionRowView(subscription: subscription)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("All Subscriptions")
        .searchable(text: externalSearchText.isEmpty ? $localSearchText : $externalSearchText, prompt: "Search subscriptions")
        .sheet(item: $subscriptionToEdit) { subscription in
            AddSubscriptionView(subscriptionToEdit: subscription.name.isEmpty && subscription.amount == 0 ? nil : subscription)
        }
    }
}

struct CategoryTag: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? .blue : .blue.opacity(0.1))
                .foregroundStyle(isSelected ? .white : .blue)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SubscriptionsListView()
            .modelContainer(for: Subscription.self, inMemory: true)
    }
}
