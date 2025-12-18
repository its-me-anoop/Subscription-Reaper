//
//  SettingsView.swift
//  Subscription Reaper
//
//  Created by Antigravity on 18/12/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackgroundView()
                
                List {
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
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
