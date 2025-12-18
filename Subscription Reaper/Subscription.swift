//
//  Subscription.swift
//  Subscription Reaper
//
//  Created by Antigravity on 18/12/2025.
//

import Foundation
import SwiftData

@Model
final class Subscription: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Double
    var currency: String
    var frequency: String // "Monthly", "Yearly"
    var category: String
    var icon: String // SF Symbol name
    var startDate: Date
    var nextBillingDate: Date
    var notes: String?
    
    init(
        id: UUID = UUID(),
        name: String = "",
        amount: Double = 0.0,
        currency: String = "USD",
        frequency: String = "Monthly",
        category: String = "General",
        icon: String = "creditcard.fill",
        startDate: Date = Date(),
        nextBillingDate: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.currency = currency
        self.frequency = frequency
        self.category = category
        self.icon = icon
        self.startDate = startDate
        self.nextBillingDate = nextBillingDate
        self.notes = notes
    }
}
