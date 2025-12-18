//
//  NotificationManager.swift
//  Subscription Reaper
//
//  Created by Antigravity on 18/12/2025.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted.")
            } else if let error = error {
                print("Notification permissions error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(for subscription: Subscription) {
        Task {
            // Generate personalized content
            let content = UNMutableNotificationContent()
            content.sound = .default
            
            if let personalized = await NotificationGenerator.shared.generateNotification(for: subscription) {
                content.title = personalized.title
                content.body = personalized.body
            } else {
                // Fallback content
                content.title = "\(subscription.name) Renewal"
                content.body = "Your \(subscription.name) subscription for \(subscription.amount) \(subscription.currency) is renewing tomorrow."
            }
            
            // Calculate trigger date (1 day before nextBillingDate)
            let calendar = Calendar.current
            guard let triggerDate = calendar.date(byAdding: .day, value: -1, to: subscription.nextBillingDate) else { return }
            
            // Use date components for the trigger
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            // For testing purposes, if the date is in the past, we might want to trigger it soon or just skip
            // In a real app, we'd ensure it's in the future.
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: subscription.id.uuidString,
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
                print("Scheduled notification for \(subscription.name) on \(triggerDate)")
            } catch {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func cancelNotification(for subscription: Subscription) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [subscription.id.uuidString])
        print("Cancelled notification for \(subscription.name)")
    }
}
