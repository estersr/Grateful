//
//  GratitudeStore.swift
//  Grateful
//
//  Created by Esther Ramos on 13/01/26.
//

import Foundation
import Combine
import SwiftUI

class GratitudeStore: ObservableObject {
    @Published var entries: [GratitudeEntry] = []
    @Published var currentStreak: Int = 0
    @Published var totalEntries: Int = 0
    
    private let saveKey = "GratitudeEntries"
    private let streakKey = "CurrentStreak"
    private let lastEntryDateKey = "LastEntryDate"
    
    init() {
        loadEntries()
        calculateStreak()
    }
    
    func addEntry(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let entry = GratitudeEntry(content: content, date: Date())
        entries.insert(entry, at: 0) // Newest first
        totalEntries += 1
        updateStreak()
        saveEntries()
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func toggleFavorite(_ entry: GratitudeEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index].isFavorite.toggle()
            saveEntries()
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func deleteEntry(_ entry: GratitudeEntry) {
        entries.removeAll { $0.id == entry.id }
        totalEntries = entries.count
        saveEntries()
    }
    
    func deleteEntry(at indexSet: IndexSet) {
        entries.remove(atOffsets: indexSet)
        totalEntries = entries.count
        saveEntries()
    }
    
    func entriesForDate(_ date: Date) -> [GratitudeEntry] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    func entriesForMonth(_ date: Date) -> [GratitudeEntry] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return entries.filter { entry in
            let entryMonth = calendar.component(.month, from: entry.date)
            let entryYear = calendar.component(.year, from: entry.date)
            return entryMonth == month && entryYear == year
        }
    }
    
    private func updateStreak() {
        let today = Date()
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: today)
        
        guard let lastEntryDate = UserDefaults.standard.object(forKey: lastEntryDateKey) as? Date else {
            // First entry
            currentStreak = 1
            UserDefaults.standard.set(todayStart, forKey: lastEntryDateKey)
            UserDefaults.standard.set(currentStreak, forKey: streakKey)
            return
        }
        
        let lastEntryStart = calendar.startOfDay(for: lastEntryDate)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: todayStart)!
        
        if lastEntryStart == todayStart {
            // Already logged today
            return
        } else if lastEntryStart == yesterday {
            // Logged yesterday, continue streak
            currentStreak += 1
        } else {
            // Missed a day, reset streak
            currentStreak = 1
        }
        
        UserDefaults.standard.set(todayStart, forKey: lastEntryDateKey)
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
    }
    
    private func calculateStreak() {
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        totalEntries = entries.count
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([GratitudeEntry].self, from: data) {
            entries = decoded.sorted { $0.date > $1.date } // Newest first
        } else {
            // Add sample entries for first-time users
            addSampleEntries()
        }
    }
    
    private func addSampleEntries() {
        let calendar = Calendar.current
        let today = Date()
        
        // Add 3 sample entries from past days
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) {
            
            let sampleEntries = [
                GratitudeEntry(content: "The warm sunshine on my face this morning", date: today, isFavorite: true),
                GratitudeEntry(content: "A good conversation with an old friend", date: yesterday, isFavorite: true),
                GratitudeEntry(content: "Finding time to read a book I enjoy", date: twoDaysAgo)
            ]
            
            entries = sampleEntries
            saveEntries()
        }
    }
}
