//
//  SubscriptionDetailView.swift
//  Subscription Reaper
//
//  Created by Antigravity on 18/12/2025.
//

import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedCountry") private var selectedCountry = "US"
    
    let subscription: Subscription
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.blue.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .blur(radius: 20)
                            
                            if let logoUrl = subscription.logoUrl, let url = URL(string: logoUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 80)
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Image(systemName: subscription.icon)
                                    .font(.system(size: 60))
                                    .foregroundStyle(.blue)
                                    .symbolEffect(.bounce, value: true)
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text(subscription.fullServiceName ?? subscription.name)
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text(subscription.category)
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 40)
                    
                    // Cost Comparison Card
                    VStack(spacing: 20) {
                        HStack(spacing: 0) {
                            CostColumn(
                                label: "Monthly",
                                amount: subscription.frequency == "Monthly" ? subscription.amount : subscription.amount / 12,
                                currency: subscription.currency
                            )
                            
                            Divider()
                                .frame(height: 60)
                                .padding(.horizontal)
                            
                            CostColumn(
                                label: "Annual",
                                amount: subscription.frequency == "Yearly" ? subscription.amount : subscription.amount * 12,
                                currency: subscription.currency
                            )
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        
                        // Billing Info
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Next Billing", systemImage: "calendar")
                                    .font(.headline)
                                Spacer()
                                Text(subscription.nextBillingDate, style: .date)
                                    .fontWeight(.medium)
                            }
                            
                            let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: subscription.nextBillingDate).day ?? 0
                            
                            HStack {
                                Label("Remaining", systemImage: "clock")
                                    .font(.headline)
                                Spacer()
                                Text("\(daysRemaining) days")
                                    .fontWeight(.bold)
                                    .foregroundStyle(daysRemaining < 3 ? .red : .primary)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(.horizontal)
                    
                    
                    // Notes Section
                    if let notes = subscription.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                            
                            Text(notes)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal)
                    }
                    
                    // Delete Button
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Subscription", systemImage: "trash")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddSubscriptionView(subscriptionToEdit: subscription)
        }
        .alert("Delete Subscription", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                modelContext.delete(subscription)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(subscription.name)'? This action cannot be undone.")
        }
        .task {
            // No longer fetching plans, focusing on manual entry
        }
    }
}

struct CostColumn: View {
    let label: String
    let amount: Double
    let currency: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(amount.formatted(.currency(code: currency)))
                .font(.system(.title2, design: .rounded, weight: .bold))
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    NavigationStack {
        SubscriptionDetailView(subscription: Subscription(
            name: "Netflix",
            amount: 15.49,
            currency: "USD",
            frequency: "Monthly",
            category: "Entertainment",
            icon: "play.tv.fill",
            startDate: Date(),
            nextBillingDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
            notes: "Shared with the family."
        ))
    }
}
