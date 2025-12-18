//
//  CurrencyService.swift
//  Subscription Reaper
//

import Foundation
import Observation

@Observable
class CurrencyService {
    static let shared = CurrencyService()
    
    private(set) var rates: [String: Double] = ["USD": 1.0, "EUR": 0.92, "GBP": 0.79, "INR": 83.3, "JPY": 150.0]
    private(set) var lastUpdated: Date?
    
    private init() {
        Task {
            await fetchRates()
        }
    }
    
    func convert(_ amount: Double, from fromCurrency: String, to toCurrency: String) -> Double {
        guard let fromRate = rates[fromCurrency], let toRate = rates[toCurrency] else {
            return amount
        }
        
        // Convert to USD first (base), then to target
        let usdAmount = amount / fromRate
        return usdAmount * toRate
    }
    
    func fetchRates() async {
        guard let url = URL(string: "https://api.frankfurter.app/latest?from=USD") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(FrankfurterResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.rates = response.rates
                self.rates["USD"] = 1.0
                self.lastUpdated = Date()
            }
        } catch {
            print("Failed to fetch rates: \(error)")
        }
    }
}

struct FrankfurterResponse: Codable {
    let amount: Double
    let base: String
    let date: String
    let rates: [String: Double]
}
