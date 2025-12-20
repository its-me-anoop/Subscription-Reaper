//
//  SettingsView.swift
//  Subscription Reaper
//
//  Created by Antigravity on 18/12/2025.
//

import SwiftUI

struct SettingsView: View {
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("isBudgetEnabled") private var isBudgetEnabled = false
    @AppStorage("monthlyBudget") private var monthlyBudget: Double = 50.0
    @AppStorage("annualBudget") private var annualBudget: Double = 600.0
    @AppStorage("selectedCountry") private var selectedCountry = "US"
    @AppStorage("geminiApiKey") private var geminiApiKey = ""
    
    let countries = [
        "US": "United States",
        "UK": "United Kingdom",
        "IN": "India",
        "EU": "Europe",
        "AU": "Australia",
        "CA": "Canada",
        "JP": "Japan"
    ]
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView()
            
            List {
                Section {
                    Picker("Default Currency", selection: $defaultCurrency) {
                        ForEach(["USD", "EUR", "GBP", "INR", "JPY", "AUD", "CAD"], id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                    
                    Picker("Country", selection: $selectedCountry) {
                        ForEach(countries.keys.sorted(), id: \.self) { code in
                            Text(countries[code] ?? code).tag(code)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                } header: {
                    Text("General")
                } footer: {
                    if let lastUpdated = CurrencyService.shared.lastUpdated {
                        Text("Rates last updated: \(lastUpdated.formatted())")
                    } else {
                        Text("Using default offline rates")
                    }
                }

                Section {
                    SecureField("Gemini API Key", text: $geminiApiKey)
                        .textContentType(.password)
                    
                    Text("Analysis is powered by Gemini 3 Flash for cutting-edge reasoning. Apple's Foundation Model is used as a secure on-device fallback if no key is provided.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                } header: {
                    Text("AI Configuration")
                } footer: {
                    Link("Get a Free API Key here", destination: URL(string: "https://aistudio.google.com/app/apikey")!)
                        .font(.system(size: 11))
                }
                .listRowBackground(Color.white.opacity(0.1))

                Section {
                    Toggle("Enable Budget Tracking", isOn: $isBudgetEnabled)
                    
                    if isBudgetEnabled {
                        HStack {
                            Text("Monthly Budget")
                            Spacer()
                            TextField("Amount", value: $monthlyBudget, format: .currency(code: defaultCurrency))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Annual Budget")
                            Spacer()
                            TextField("Amount", value: $annualBudget, format: .currency(code: defaultCurrency))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                } header: {
                    Text("Budget")
                } footer: {
                    Text("Set your spending limits to see alerts on the dashboard.")
                }
                .listRowBackground(Color.white.opacity(0.1))

                Section {
                    NavigationLink {
                        Text("Account Settings")
                    } label: {
                        Label("Account", systemImage: "person.circle")
                    }
                    
                    NavigationLink {
                        Text("Notification Settings")
                    } label: {
                        Label("Notifications", systemImage: "bell.badge")
                    }
                    
                    NavigationLink {
                        Text("Appearance Settings")
                    } label: {
                        Label("Appearance", systemImage: "paintbrush")
                    }
                } header: {
                    Text("Preferences")
                }
                .listRowBackground(Color.white.opacity(0.1))
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Anoop Jose")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("App Information")
                }
                .listRowBackground(Color.white.opacity(0.1))
                
                Section {
                    Button(role: .destructive) {
                        // Reset action
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }
                .listRowBackground(Color.white.opacity(0.1))
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    selectedTab = 0
                }
            }
        }
    }
}

#Preview {
    SettingsView(selectedTab: .constant(3))
}
