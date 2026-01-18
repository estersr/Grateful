//
//  GratitudeEntry.swift
//  Grateful
//
//  Created by Esther Ramos on 13/01/26.
//

import Foundation
import SwiftUI

struct GratitudeEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let date: Date
    var isFavorite: Bool
    
    init(id: UUID = UUID(), content: String, date: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.content = content
        self.date = date
        self.isFavorite = isFavorite
    }
    
    static func == (lhs: GratitudeEntry, rhs: GratitudeEntry) -> Bool {
        lhs.id == rhs.id
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(date)
    }
    
    var isThisWeek: Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        return date > weekAgo && date <= now
    }
}

// For inspirational quotes
struct Quote: Identifiable {
    let id = UUID()
    let text: String
    let author: String
    
    static let dailyQuotes = [
        Quote(text: "Gratitude turns what we have into enough.", author: "Anonymous"),
        Quote(text: "The more grateful I am, the more beauty I see.", author: "Mary Davis"),
        Quote(text: "Gratitude is the healthiest of all human emotions.", author: "Zig Ziglar"),
        Quote(text: "Enjoy the little things, for one day you may look back and realize they were the big things.", author: "Robert Brault"),
        Quote(text: "Gratitude makes sense of our past, brings peace for today, and creates a vision for tomorrow.", author: "Melody Beattie"),
        Quote(text: "When I started counting my blessings, my whole life turned around.", author: "Willie Nelson"),
        Quote(text: "The root of joy is gratefulness.", author: "David Steindl-Rast"),
        Quote(text: "Gratitude is the wine for the soul. Go on. Get drunk.", author: "Rumi"),
        Quote(text: "What separates privilege from entitlement is gratitude.", author: "Brené Brown"),
        Quote(text: "A grateful mind is a great mind which eventually attracts to itself great things.", author: "Plato")
    ]
    
    static func randomQuote() -> Quote {
        dailyQuotes.randomElement() ?? dailyQuotes[0]
    }
}

// For beautiful gradient backgrounds
struct GradientPreset: Identifiable {
    let id = UUID()
    let name: String
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    static let allPresets: [GradientPreset] = [
        GradientPreset(name: "Sunset", colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
        GradientPreset(name: "Ocean", colors: [.blue, .teal, .cyan], startPoint: .top, endPoint: .bottom),
        GradientPreset(name: "Forest", colors: [.green, .mint, .teal], startPoint: .leading, endPoint: .trailing),
        GradientPreset(name: "Berry", colors: [.purple, .indigo, .blue], startPoint: .topTrailing, endPoint: .bottomLeading),
        GradientPreset(name: "Citrus", colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottomTrailing),
        GradientPreset(name: "Dawn", colors: [.pink, .orange, .yellow], startPoint: .leading, endPoint: .trailing),
        GradientPreset(name: "Twilight", colors: [.indigo, .purple, .pink], startPoint: .topLeading, endPoint: .bottom),
        GradientPreset(name: "Mint", colors: [.mint, .cyan, .blue], startPoint: .bottomLeading, endPoint: .topTrailing),
        GradientPreset(name: "Sunrise", colors: [.red, .orange, .yellow], startPoint: .bottom, endPoint: .top),
        GradientPreset(name: "Lavender", colors: [.purple, .blue, .indigo], startPoint: .top, endPoint: .bottom)
    ]
}
