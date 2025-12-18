//
//  AddSubscriptionView.swift
//  Subscription Reaper
//
//  Created by Antigravity on 18/12/2025.
//

import SwiftUI
import SwiftData
import FoundationModels

@Generable
struct SubscriptionPrediction: Equatable {
    @Guide(description: "The most likely official name of the subscription service.")
    let name: String
    
    @Guide(description: "The category, must be one of: Entertainment, Productivity, Health, Utilities, Food, Other.")
    let category: String
    
    @Guide(description: "A suitable SF Symbol name representing this specific subscription service.")
    let iconName: String
}

struct AddSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var amount: Double = 0.0
    @State private var currency: String = "USD"
    @State private var frequency: String = "Monthly"
    @State private var category: String = "Entertainment"
    @State private var icon: String = "creditcard.fill"
    @State private var startDate: Date = Date()
    @State private var nextBillingDate: Date = Date()
    @State private var notes: String = ""
    
    // Tracking manual overrides
    @State private var isCategoryManual = false
    @State private var isIconManual = false
    @State private var isNextBillingManual = false
    @State private var isPredicting = false
    
    // Model Session
    @State private var modelSession: LanguageModelSession?
    @State private var predictionTask: Task<Void, Never>?
    
    private let frequencies = ["Monthly", "Yearly", "Weekly"]
    private let categories = ["Entertainment", "Productivity", "Health", "Utilities", "Food", "Other"]
    private let currencies = ["USD", "EUR", "GBP", "JPY", "INR"]
    private let icons = ["tv.fill", "music.note", "cloud.fill", "photo.fill", "gamecontroller.fill", "cart.fill", "heart.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    HStack {
                        TextField("Name", text: $name)
                            .onChange(of: name) { oldValue, newValue in
                                debouncePrediction(for: newValue)
                            }
                        
                        if isPredicting {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("Amount", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Currency", selection: $currency) {
                        ForEach(currencies, id: \.self) { curr in
                            Text(curr).tag(curr)
                        }
                    }
                }
                
                Section("Billing Details") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { freq in
                            Text(freq).tag(freq)
                        }
                    }
                    .onChange(of: frequency) { updateNextBillingDate() }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .onChange(of: startDate) { updateNextBillingDate() }
                    
                    DatePicker("Next Billing", selection: $nextBillingDate, displayedComponents: .date)
                        .onChange(of: nextBillingDate) { isNextBillingManual = true }
                }
                
                Section("Style & Category") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .onChange(of: category) { isCategoryManual = true }
                    
                    Picker("Icon", selection: $icon) {
                        ForEach(icons, id: \.self) { iconName in
                            Image(systemName: iconName).tag(iconName)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: icon) { isIconManual = true }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSubscription()
                    }
                    .disabled(name.isEmpty || amount <= 0)
                }
            }
            .task {
                do {
                    modelSession = try await LanguageModelSession()
                } catch {
                    print("Failed to initialize LanguageModelSession: \(error)")
                }
            }
            .onAppear {
                updateNextBillingDate()
            }
        }
    }
    
    private func debouncePrediction(for newValue: String) {
        predictionTask?.cancel()
        
        guard !newValue.isEmpty, newValue.count >= 2 else { return }
        
        predictionTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
            guard !Task.isCancelled else { return }
            
            await performPrediction(for: newValue)
        }
    }
    
    private func performPrediction(for query: String) async {
        guard let session = modelSession else { return }
        
        isPredicting = true
        defer { isPredicting = false }
        
        do {
            let response = try await session.generateResponse(generating: SubscriptionPrediction.self) {
                "Predict the standard service name, category, and SF Symbol icon for this subscription input: \(query)"
            }
            
            let prediction = response.content
            
            await MainActor.run {
                if !isCategoryManual && categories.contains(prediction.category) {
                    withAnimation { category = prediction.category }
                }
                if !isIconManual {
                    withAnimation { icon = prediction.iconName }
                }
                // Optionally update name if it matches well, but keep user input for better UX
                // name = prediction.name
            }
        } catch {
            print("Prediction failed: \(error)")
        }
    }
    
    private func updateNextBillingDate() {
        guard !isNextBillingManual else { return }
        
        var dateComponent = DateComponents()
        switch frequency {
        case "Monthly":
            dateComponent.month = 1
        case "Yearly":
            dateComponent.year = 1
        case "Weekly":
            dateComponent.day = 7
        default:
            break
        }
        
        if let nextDate = Calendar.current.date(byAdding: dateComponent, to: startDate) {
            withAnimation {
                nextBillingDate = nextDate
            }
        }
    }
    
    private func saveSubscription() {
        let newSubscription = Subscription(
            name: name,
            amount: amount,
            currency: currency,
            frequency: frequency,
            category: category,
            icon: icon,
            startDate: startDate,
            nextBillingDate: nextBillingDate,
            notes: notes.isEmpty ? nil : notes
        )
        modelContext.insert(newSubscription)
        dismiss()
    }
}

#Preview {
    AddSubscriptionView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
