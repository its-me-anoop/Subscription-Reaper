//
//  NotificationGenerator.swift
//  Subscription Reaper
//
//  Created by Antigravity on 18/12/2025.
//

import Foundation
import FoundationModels

@Generable
struct PersonalizedNotification: Equatable {
    @Guide(description: "A punchy, short title for a subscription renewal notification. Should be personal and mention the service name.")
    let title: String
    
    @Guide(description: "A friendly, unique, and personal message body. It should mention the amount and frequency, and perhaps a small encouraging or witty comment. Keep it under 100 characters.")
    let body: String
}

class NotificationGenerator {
    static let shared = NotificationGenerator()
    
    private let modelSession = LanguageModelSession()
    
    func generateNotification(for subscription: Subscription) async -> (title: String, body: String)? {
        let prompt = """
        Generate a personalized renewal notification for the following subscription:
        Name: \(subscription.name)
        Amount: \(subscription.amount) \(subscription.currency)
        Frequency: \(subscription.frequency)
        Category: \(subscription.category)
        
        The tone should be friendly, helpful, and slightly personal.
        """
        
        do {
            let response = try await modelSession.respond(
                to: prompt,
                generating: PersonalizedNotification.self
            )
            
            let result = response.content
            return (result.title, result.body)
        } catch {
            print("Failed to generate personalized notification: \(error)")
            return nil
        }
    }
}
