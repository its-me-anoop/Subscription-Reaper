//
//  Subscription_ReaperApp.swift
//  Subscription Reaper
//
//  Created by Anoop Jose on 17/12/2025.
//

import SwiftUI
import SwiftData

@main
struct Subscription_ReaperApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Subscription.self,
        ])
        
        let modelConfiguration: ModelConfiguration
        
        // Ensure Application Support directory exists to prevent CoreData errors
        let fileManager = FileManager.default
        if let supportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
             // Create directory if it doesn't exist
            if !fileManager.fileExists(atPath: supportDir.path) {
                do {
                    try fileManager.createDirectory(at: supportDir, withIntermediateDirectories: true, attributes: nil)
                    print("Created Application Support directory for SwiftData")
                } catch {
                    print("Failed to create Application Support directory: \(error)")
                }
            }
            
            // Explicitly set the URL for the store
            let databaseURL = supportDir.appendingPathComponent("default.store")
            modelConfiguration = ModelConfiguration(schema: schema, url: databaseURL)
        } else {
             // Fallback if we can't get the URL (unlikely)
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("Successfully initialized ModelContainer")
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                        .onAppear {
                            NotificationManager.shared.requestPermissions()
                        }
                } else {
                    IntroView()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
