//
//  AnalysisView.swift
//  Subscription Reaper
//
//  Created by Antigravity on 18/12/2025.
//

import SwiftUI
import Charts
import SwiftData

struct AnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var subscriptions: [Subscription]
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("selectedCountry") private var selectedCountry = "US"
    
    @State private var analysisResult: AnalysisResult?
    @State private var isLoading = false
    
    var categoryData: [(category: String, amount: Double)] {
        let groups = Dictionary(grouping: subscriptions) { $0.category }
        return groups.map { (category, subs) in
            let total = subs.reduce(0.0) { sum, sub in
                let monthly = sub.frequency == "Monthly" ? sub.amount : (sub.amount / 12.0)
                return sum + CurrencyService.shared.convert(monthly, from: sub.currency, to: defaultCurrency)
            }
            return (category: category, amount: total)
        }.sorted { $0.amount > $1.amount }
    }
    
    var totalMonthlySpending: Double {
        categoryData.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ZStack {
            AnimatedBackgroundView()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Spending Overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Spending by Category")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(categoryData, id: \.category) { item in
                                BarMark(
                                    x: .value("Category", item.category),
                                    y: .value("Monthly Amount", item.amount)
                                )
                                .foregroundStyle(by: .value("Category", item.category))
                                .cornerRadius(12)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(24)
                        .padding(.horizontal)
                        .chartLegend(.hidden)
                    }
                    
                    // Smart Insights Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Smart Insights")
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.shield.fill")
                                        .foregroundStyle(.green)
                                    Text("Grounded in 2025/26 Market Data (\(selectedCountry))")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                                
                                Text("Powered by \(SavingsPredictor.shared.activeEngine.rawValue)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.blue.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            if isLoading {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Button {
                                    runAnalysis()
                                } label: {
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if isLoading && analysisResult == nil {
                            VStack(spacing: 20) {
                                ForEach(0..<3) { _ in
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                        .frame(height: 100)
                                        .overlay {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Capsule().fill(.secondary.opacity(0.1)).frame(width: 150, height: 12)
                                                    Capsule().fill(.secondary.opacity(0.1)).frame(width: 100, height: 8)
                                                    Capsule().fill(.secondary.opacity(0.1)).frame(width: 200, height: 8)
                                                }
                                                Spacer()
                                            }
                                            .padding()
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .transition(.opacity)
                        } else if let result = analysisResult {
                            VStack(spacing: 16) {
                                // Potential Savings Highlight
                                InsightCard(
                                    title: "Potential Savings",
                                    description: result.summary,
                                    savings: result.totalPotentialSavings,
                                    type: "Total",
                                    currencyCode: defaultCurrency,
                                    priority: 1.0,
                                    isHighlight: true
                                )
                                
                                ForEach(result.insights, id: \.title) { insight in
                                    InsightCard(
                                        title: insight.title,
                                        description: insight.description,
                                        savings: insight.potentialSavings,
                                        type: insight.type,
                                        currencyCode: defaultCurrency,
                                        priority: insight.priority
                                    )
                                }
                            }
                            .padding(.horizontal)
                        } else if !isLoading {
                            VStack(spacing: 12) {
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                                Text("Ready to analyze your spending?")
                                    .font(.headline)
                                Button("Run Smart Analysis") {
                                    runAnalysis()
                                }
                                .buttonStyle(.borderedProminent)
                                .clipShape(Capsule())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(.ultraThinMaterial)
                            .cornerRadius(24)
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
        }
        .navigationTitle("Analysis")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    runAnalysis()
                } label: {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "sparkles")
                            .symbolEffect(.bounce, value: isLoading)
                    }
                }
                .disabled(isLoading || subscriptions.isEmpty)
            }
        }
        .onAppear {
            if analysisResult == nil {
                runAnalysis()
            }
        }
    }
    
    private func runAnalysis() {
        guard !subscriptions.isEmpty else { return }
        isLoading = true
        Task {
            let result = await SavingsPredictor.shared.analyzeSubscriptions(
                subscriptions,
                defaultCurrency: defaultCurrency,
                country: selectedCountry
            )
            await MainActor.run {
                self.analysisResult = result
                self.isLoading = false
            }
        }
    }
}

struct InsightCard: View {
    let title: String
    let description: String
    let savings: Double
    let type: String
    let currencyCode: String
    let priority: Double
    var isHighlight: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Text(type.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(isHighlight ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if savings > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("+\(savings.formatted(.currency(code: currencyCode)))")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(isHighlight ? .white : .green)
                        Text("monthly")
                            .font(.system(size: 10))
                            .foregroundStyle(isHighlight ? .white.opacity(0.7) : .secondary)
                    }
                }
            }
            
            Text(description)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(isHighlight ? .white.opacity(0.9) : .primary)
                .foregroundStyle(isHighlight ? .white.opacity(0.9) : .primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(isHighlight ? Color.blue.gradient : Color.clear.gradient)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isHighlight ? .white.opacity(0.2) : .secondary.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        AnalysisView()
            .modelContainer(for: Subscription.self, inMemory: true)
    }
}
