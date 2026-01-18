//
//  ContentView.swift
//  Grateful
//
//  Created by Esther Ramos on 13/01/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gratitudeStore: GratitudeStore
    @State private var newEntryText = ""
    @State private var showingStats = false
    @State private var showingCalendar = false
    @State private var showingSettings = false
    @State private var selectedDate = Date()
    @State private var isWriting = false
    @State private var showInspiration = false
    @State private var currentQuote = Quote.randomQuote()
    @AppStorage("selectedTheme") private var selectedTheme = "Sunset"
    
    var currentGradient: GradientPreset {
        GradientPreset.allPresets.first { $0.name == selectedTheme } ?? GradientPreset.allPresets[0]
    }
    
    var todaysEntries: [GratitudeEntry] {
        gratitudeStore.entriesForDate(Date())
    }
    
    var favoriteEntries: [GratitudeEntry] {
        gratitudeStore.entries.filter { $0.isFavorite }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: currentGradient.colors,
                    startPoint: currentGradient.startPoint,
                    endPoint: currentGradient.endPoint
                )
                .opacity(0.15)
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header with Stats
                        headerView
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        // Writing Area
                        writingArea
                            .padding(.horizontal, 20)
                        
                        // Quote of the Day
                        if showInspiration {
                            quoteCard
                                .padding(.horizontal, 20)
                        }
                        
                        // Today's Entries
                        if !todaysEntries.isEmpty {
                            todayEntriesView
                                .padding(.horizontal, 20)
                        }
                        
                        // Favorites Section
                        if !favoriteEntries.isEmpty {
                            favoritesView
                                .padding(.horizontal, 20)
                        }
                        
                        // All Entries
                        if !gratitudeStore.entries.isEmpty {
                            allEntriesView
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, 20)
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if isWriting {
                            submitButton
                        } else {
                            writeButton
                        }
                    }
                }
            }
            .navigationTitle("Grateful")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingStats.toggle() }) {
                        Image(systemName: "chart.bar")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingCalendar.toggle() }) {
                            Label("Calendar", systemImage: "calendar")
                        }
                        
                        Button(action: { showInspiration.toggle() }) {
                            Label(showInspiration ? "Hide Inspiration" : "Show Inspiration",
                                  systemImage: showInspiration ? "quote.bubble.fill" : "quote.bubble")
                        }
                        
                        Button(action: { showingSettings.toggle() }) {
                            Label("Settings", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingStats) {
                StatsView()
                    .environmentObject(gratitudeStore)
            }
            .sheet(isPresented: $showingCalendar) {
                CalendarView(selectedDate: $selectedDate)
                    .environmentObject(gratitudeStore)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onAppear {
                // Randomly show inspiration on launch
                showInspiration = Bool.random()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Today's Gratitude")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(gratitudeStore.currentStreak)")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                        Text("day streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                            .foregroundColor(.blue)
                        Text("\(gratitudeStore.totalEntries)")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                        Text("entries")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Quick Stats Circle
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 70, height: 70)
                
                VStack(spacing: 2) {
                    Text("\(todaysEntries.count)")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                    
                    Text("today")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var writingArea: some View {
        VStack(spacing: 15) {
            if isWriting {
                // Writing Mode
                VStack(alignment: .leading, spacing: 10) {
                    Text("What are you grateful for today?")
                        .font(.headline)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $newEntryText)
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                        
                        if newEntryText.isEmpty {
                            Text("I'm grateful for...")
                                .foregroundColor(.secondary)
                                .padding(.top, 20)
                                .padding(.leading, 16)
                                .allowsHitTesting(false)
                        }
                    }
                    
                    HStack {
                        Text("\(newEntryText.count)/280")
                            .font(.caption)
                            .foregroundColor(newEntryText.count > 280 ? .red : .secondary)
                        
                        Spacer()
                        
                        Button("Cancel") {
                            withAnimation {
                                isWriting = false
                                newEntryText = ""
                            }
                        }
                        .font(.subheadline)
                    }
                }
            } else {
                // Prompt Mode
                VStack(spacing: 12) {
                    Text("Start your gratitude practice")
                        .font(.headline)
                    
                    Text("Take a moment to reflect on something positive from your day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Quick prompts
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(quickPrompts, id: \.self) { prompt in
                                Button(action: {
                                    withAnimation {
                                        isWriting = true
                                        newEntryText = prompt
                                    }
                                }) {
                                    Text(prompt)
                                        .font(.caption)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(.ultraThinMaterial)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
            }
        }
    }
    
    private var quickPrompts: [String] {
        [
            "A person who helped me",
            "A moment of joy",
            "Something I learned",
            "A beautiful sight",
            "A small victory",
            "Comfort I received",
            "Nature's gift",
            "Kindness I witnessed"
        ]
    }
    
    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.opening")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Daily Inspiration")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    currentQuote = Quote.randomQuote()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
            }
            
            Text("\(currentQuote.text)")
                .font(.body)
                .italic()
            
            Text("— \(currentQuote.author)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var todayEntriesView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Today")
                    .font(.headline)
                
                Spacer()
                
                Text("\(todaysEntries.count) entry\(todaysEntries.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(todaysEntries) { entry in
                    GratitudeCard(entry: entry)
                }
            }
        }
    }
    
    private var favoritesView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                
                Text("Favorites")
                    .font(.headline)
                
                Spacer()
                
                Text("\(favoriteEntries.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(favoriteEntries.prefix(5)) { entry in
                        FavoriteCard(entry: entry)
                    }
                }
            }
        }
    }
    
    private var allEntriesView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Entries")
                .font(.headline)
            
            LazyVStack(spacing: 15) {
                ForEach(gratitudeStore.entries.prefix(5)) { entry in
                    EntryRow(entry: entry)
                }
            }
        }
    }
    
    private var writeButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isWriting = true
            }
        }) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: currentGradient.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(.trailing, 20)
        .padding(.bottom, 30)
    }
    
    private var submitButton: some View {
        Button(action: {
            gratitudeStore.addEntry(newEntryText)
            newEntryText = ""
            withAnimation {
                isWriting = false
            }
        }) {
            ZStack {
                Circle()
                    .fill(.green)
                    .frame(width: 60, height: 60)
                    .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(.trailing, 20)
        .padding(.bottom, 30)
        .disabled(newEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || newEntryText.count > 280)
    }
}

struct GratitudeCard: View {
    let entry: GratitudeEntry
    @EnvironmentObject var gratitudeStore: GratitudeStore
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Time
            VStack {
                Text(entry.timeString)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 1, height: 50)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.content)
                    .font(.body)
                    .lineSpacing(4)
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        gratitudeStore.toggleFavorite(entry)
                    }) {
                        Image(systemName: entry.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(entry.isFavorite ? .red : .secondary)
                    }
                }
            }
            .padding(.leading, 5)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
        )
        .contextMenu {
            Button(role: .destructive) {
                gratitudeStore.deleteEntry(entry)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct FavoriteCard: View {
    let entry: GratitudeEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.caption2)
                    .foregroundColor(.red)
                
                Spacer()
                
                Text(entry.timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.content)
                .font(.caption)
                .lineLimit(3)
                .lineSpacing(2)
        }
        .frame(width: 150)
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
    }
}

struct EntryRow: View {
    let entry: GratitudeEntry
    
    var body: some View {
        HStack(spacing: 15) {
            // Date indicator
            VStack(spacing: 4) {
                Text(entry.dayOfWeek.prefix(3).uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Text(entry.date, style: .date)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            
            // Content preview
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.content)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack {
                    if entry.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    Text(entry.relativeDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}
