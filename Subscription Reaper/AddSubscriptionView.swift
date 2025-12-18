//
//  AddSubscriptionView.swift
//  Subscription Reaper
//
//  Created by Antigravity on 18/12/2025.
//

import SwiftUI
import SwiftData

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
    
    private let frequencies = ["Monthly", "Yearly", "Weekly"]
    private let categories = ["Entertainment", "Productivity", "Health", "Utilities", "Food", "Other"]
    private let currencies = ["USD", "EUR", "GBP", "JPY", "INR"]
    private let icons = ["tv.fill", "music.note", "cloud.fill", "photo.fill", "gamecontroller.fill", "cart.fill", "heart.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Name", text: $name)
                    
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
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("Next Billing", selection: $nextBillingDate, displayedComponents: .date)
                }
                
                Section("Style & Category") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
                    Picker("Icon", selection: $icon) {
                        ForEach(icons, id: \.self) { iconName in
                            Image(systemName: iconName).tag(iconName)
                        }
                    }
                    .pickerStyle(.segmented)
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
