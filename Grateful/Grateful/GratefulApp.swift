//
//  GratefulApp.swift
//  Grateful
//
//  Created by Esther Ramos on 13/01/26.
//

import SwiftUI

@main
struct GratefulApp: App {
    @StateObject private var gratitudeStore = GratitudeStore()
    @AppStorage("selectedTheme") private var selectedTheme = "Sunset"
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gratitudeStore)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
