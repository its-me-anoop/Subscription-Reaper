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
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("selectedCountry") private var selectedCountry = "US"
    
    var subscriptionToEdit: Subscription?
    
    @State private var name: String = ""
    @State private var amount: Double = 0.0
    @State private var amountString: String = ""
    @State private var currency: String = "USD"
    @State private var frequency: String = "Monthly"
    @State private var category: String = "Entertainment"
    @State private var icon: String = "creditcard.fill"
    @State private var startDate: Date = Date()
    @State private var nextBillingDate: Date = Date()
    @State private var notes: String = ""
    @State private var logoUrl: String? = nil
    @State private var fullServiceName: String? = nil
    @State private var sourceId: String? = nil
    
    // Tracking manual overrides
    @State private var isCategoryManual = false
    @State private var isIconManual = false
    @State private var isNextBillingManual = false
    @State private var isPredicting = false
    @State private var suggestedSources: [StreamingSource] = []
    @State private var isLoadingSuggestions = false
    
    // Model Session
    @State private var modelSession: LanguageModelSession?
    @State private var predictionTask: Task<Void, Never>?
    
    private let frequencies = ["Monthly", "Yearly", "Weekly"]
    private let categories = ["Entertainment", "Productivity", "Health", "Utilities", "Food", "Other"]
    private let currencies = ["USD", "EUR", "GBP", "JPY", "INR", "AUD", "CAD"]
    @State private var icons = ["tv.fill", "music.note", "cloud.fill", "photo.fill", "gamecontroller.fill", "cart.fill", "heart.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    HStack {
                        TextField("Name", text: $name)
                            .onChange(of: name) { oldValue, newValue in
                                debouncePrediction(for: newValue)
                            }
                        
                        if isPredicting || isLoadingSuggestions {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                    
                    if !suggestedSources.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(suggestedSources) { source in
                                    Button {
                                        selectSource(source)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 6) {
                                            if let url = URL(string: source.logoUrl) {
                                                AsyncImage(url: url) { image in
                                                    image.resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(height: 20)
                                                } placeholder: {
                                                    ProgressView().controlSize(.mini)
                                                }
                                            } else {
                                                Image(systemName: source.defaultIcon)
                                                    .font(.caption)
                                            }
                                            
                                            Text(source.name)
                                                .font(.system(size: 10, weight: .bold))
                                                .lineLimit(1)
                                        }
                                        .frame(width: 100, alignment: .leading)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.white.opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amountString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: amountString) { oldValue, newValue in
                                filterAmount(newValue)
                            }
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
                    
                    DatePicker("Next Billing", selection: Binding(
                        get: { nextBillingDate },
                        set: { newValue in
                            nextBillingDate = newValue
                            isNextBillingManual = true
                        }
                    ), displayedComponents: .date)
                }
                
                Section("Style & Category") {
                    Picker("Category", selection: Binding(
                        get: { category },
                        set: { newValue in
                            category = newValue
                            isCategoryManual = true
                        }
                    )) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
                    Picker("Icon", selection: Binding(
                        get: { icon },
                        set: { newValue in
                            icon = newValue
                            isIconManual = true
                        }
                    )) {
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
            .navigationTitle(subscriptionToEdit == nil ? "New Subscription" : "Edit Subscription")
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
                // Initializing the session (synchronous in this environment)
                modelSession = LanguageModelSession()
            }
            .onAppear {
                if let sub = subscriptionToEdit {
                    name = sub.name
                    amount = sub.amount
                    amountString = String(format: "%.2f", sub.amount)
                    currency = sub.currency
                    frequency = sub.frequency
                    category = sub.category
                    icon = sub.icon
                    startDate = sub.startDate
                    nextBillingDate = sub.nextBillingDate
                    notes = sub.notes ?? ""
                    logoUrl = sub.logoUrl
                    fullServiceName = sub.fullServiceName
                    sourceId = sub.sourceId
                    
                    // Since we are loading existing, we don't want to trigger auto-updates immediately
                    isCategoryManual = true
                    isIconManual = true
                    isNextBillingManual = true
                } else {
                    currency = defaultCurrency
                    updateNextBillingDate()
                }
            }

        }
    }
    
    private func debouncePrediction(for newValue: String) {
        predictionTask?.cancel()
        
        if newValue.isEmpty {
            // Reset manual overrides if the name is cleared
            isCategoryManual = false
            isIconManual = false
            return
        }
        
        guard newValue.count >= 2 else { return }
        
        predictionTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
            guard !Task.isCancelled else { return }
            
            async let prediction: Void = performPrediction(for: newValue)
            async let sourcesSelection: Void = fetchSuggestedSources(for: newValue)
            _ = await [prediction, sourcesSelection]
        }
    }
    
    private func fetchSuggestedSources(for query: String) async {
        await MainActor.run { isLoadingSuggestions = true }
        let foundSources = await PlanLookupService.shared.lookupSources(for: query)
        await MainActor.run {
            withAnimation {
                suggestedSources = foundSources
                isLoadingSuggestions = false
            }
        }
    }
    
    private func selectSource(_ source: StreamingSource) {
        withAnimation {
            name = source.name
            category = source.category
            icon = source.defaultIcon
            logoUrl = source.logoUrl
            fullServiceName = source.name
            sourceId = source.id
            
            // Mark as manual to prevent further auto-overwrites from prediction
            isCategoryManual = true
            isIconManual = true
            
            // Ensure icon is in the list
            if !icons.contains(source.defaultIcon) {
                icons.append(source.defaultIcon)
            }
        }
    }
    
    private func performPrediction(for query: String) async {
        guard let session = modelSession else { return }
        
        isPredicting = true
        defer { isPredicting = false }
        
        do {
            let response = try await session.respond(
                to: "Predict the standard service name, category, and SF Symbol icon for this subscription input: \(query)",
                generating: SubscriptionPrediction.self
            )
            
            let prediction = response.content
            
            await MainActor.run {
                if !isCategoryManual && categories.contains(prediction.category) {
                    withAnimation { category = prediction.category }
                }
                if !isIconManual {
                    // Validate if the predicted SF Symbol actually exists
                    #if canImport(UIKit)
                    let symbolExists = UIImage(systemName: prediction.iconName) != nil
                    #else
                    let symbolExists = NSImage(systemName: prediction.iconName) != nil
                    #endif
                    
                    if symbolExists {
                        // Update icon list if prediction is not in current list
                        if !icons.contains(prediction.iconName) {
                            icons.append(prediction.iconName)
                        }
                        withAnimation { icon = prediction.iconName }
                    }
                }
            }
        } catch {
            print("Prediction failed: \(error)")
        }
    }
    
    private func filterAmount(_ newValue: String) {
        // Filter out everything except numbers and decimal point
        var filtered = newValue.filter { "0123456789.".contains($0) }
        
        // Ensure only one decimal point
        let components = filtered.split(separator: ".", omittingEmptySubsequences: false)
        if components.count > 2 {
            filtered = String(components[0]) + "." + components[1...].joined(separator: "")
        }
        
        // Update the string state if it was changed by filtering
        if filtered != newValue {
            amountString = filtered
        }
        
        // Sync with the double value
        if let doubleValue = Double(filtered) {
            amount = doubleValue
        } else if filtered.isEmpty {
            amount = 0.0
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
        if let sub = subscriptionToEdit {
            sub.name = name
            sub.amount = amount
            sub.currency = currency
            sub.frequency = frequency
            sub.category = category
            sub.icon = icon
            sub.logoUrl = logoUrl
            sub.fullServiceName = fullServiceName
            sub.sourceId = sourceId
            sub.startDate = startDate
            sub.nextBillingDate = nextBillingDate
            sub.notes = notes.isEmpty ? nil : notes
            NotificationManager.shared.scheduleNotification(for: sub)
        } else {
            let newSubscription = Subscription(
                name: name,
                amount: amount,
                currency: currency,
                frequency: frequency,
                category: category,
                icon: icon,
                logoUrl: logoUrl,
                fullServiceName: fullServiceName,
                sourceId: sourceId,
                startDate: startDate,
                nextBillingDate: nextBillingDate,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(newSubscription)
            NotificationManager.shared.scheduleNotification(for: newSubscription)
        }
        dismiss()
    }
    
}

#Preview {
    AddSubscriptionView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
