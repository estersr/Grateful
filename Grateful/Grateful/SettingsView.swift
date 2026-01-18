//
//  SettingsView.swift
//  Grateful
//
//  Created by Esther Ramos on 13/01/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("selectedTheme") private var selectedTheme = "Sunset"
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("dailyReminder") private var dailyReminder = false
    @AppStorage("reminderTime") private var reminderTime = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(GradientPreset.allPresets, id: \.name) { preset in
                            HStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: preset.colors,
                                        startPoint: preset.startPoint,
                                        endPoint: preset.endPoint
                                    ))
                                    .frame(width: 20, height: 20)
                                
                                Text(preset.name)
                            }
                            .tag(preset.name)
                        }
                    }
                    
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                
                Section("Reminders") {
                    Toggle("Daily Reminder", isOn: $dailyReminder)
                    
                    if dailyReminder {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://apple.com")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://apple.com")!) {
                        HStack {
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button("Export Entries") {
                        // Export functionality would go here
                    }
                    
                    Button("Reset All Data", role: .destructive) {
                        // Reset confirmation would go here
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
