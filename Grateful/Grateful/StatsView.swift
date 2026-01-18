//
//  StatsView.swift
//  Grateful
//
//  Created by Esther Ramos on 13/01/26.
//

import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var gratitudeStore: GratitudeStore
    @Environment(\.dismiss) var dismiss
    
    var entriesByMonth: [(month: String, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: gratitudeStore.entries) { entry in
            let components = calendar.dateComponents([.year, .month], from: entry.date)
            return "\(components.year ?? 0)-\(components.month ?? 0)"
        }
        
        return grouped.map { key, entries in
            let monthInt = Int(key.split(separator: "-").last ?? "0") ?? 0
            let monthName = calendar.monthSymbols[monthInt - 1]
            return (month: String(monthName.prefix(3)), count: entries.count)
        }
        .sorted { $0.month < $1.month }
        .suffix(6) // Last 6 months
    }
    
    var entriesByWeekday: [(weekday: String, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: gratitudeStore.entries) { entry in
            calendar.component(.weekday, from: entry.date)
        }
        
        return (1...7).map { weekday in
            let count = grouped[weekday]?.count ?? 0
            let weekdayName = calendar.shortWeekdaySymbols[weekday - 1]
            return (weekday: weekdayName, count: count)
        }
    }
    
    var averageEntriesPerDay: Double {
        guard !gratitudeStore.entries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        guard let firstEntry = gratitudeStore.entries.last?.date else { return 0 }
        
        let daysBetween = calendar.dateComponents([.day], from: firstEntry, to: Date()).day ?? 1
        return Double(gratitudeStore.totalEntries) / Double(max(daysBetween, 1))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Summary Cards
                    HStack(spacing: 15) {
                        statCard(title: "Total Entries", value: "\(gratitudeStore.totalEntries)", icon: "book.fill", color: .blue)
                        
                        statCard(title: "Current Streak", value: "\(gratitudeStore.currentStreak)", icon: "flame.fill", color: .orange)
                        
                        statCard(title: "Avg/Day", value: String(format: "%.1f", averageEntriesPerDay), icon: "chart.line.uptrend.xyaxis", color: .green)
                    }
                    
                    // Monthly Activity Chart
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Monthly Activity")
                            .font(.headline)
                        
                        if #available(iOS 16.0, *) {
                            Chart(entriesByMonth, id: \.month) { item in
                                BarMark(
                                    x: .value("Month", item.month),
                                    y: .value("Entries", item.count)
                                )
                                .foregroundStyle(.blue.gradient)
                            }
                            .frame(height: 200)
                        } else {
                            // Fallback for iOS 15
                            VStack(spacing: 10) {
                                ForEach(entriesByMonth, id: \.month) { item in
                                    HStack {
                                        Text(item.month)
                                            .frame(width: 40, alignment: .leading)
                                        
                                        Rectangle()
                                            .fill(.blue)
                                            .frame(width: CGFloat(item.count) * 10, height: 20)
                                            .cornerRadius(4)
                                        
                                        Text("\(item.count)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    
                    // Weekday Distribution
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Favorite Days")
                            .font(.headline)
                        
                        HStack(spacing: 10) {
                            ForEach(entriesByWeekday, id: \.weekday) { item in
                                VStack(spacing: 8) {
                                    Text(item.weekday.prefix(1))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                    
                                    ZStack(alignment: .bottom) {
                                        Rectangle()
                                            .fill(Color(.systemGray5))
                                            .frame(width: 25, height: 100)
                                            .cornerRadius(6)
                                        
                                        Rectangle()
                                            .fill(.blue)
                                            .frame(width: 25, height: CGFloat(min(item.count * 20, 100)))
                                            .cornerRadius(6)
                                    }
                                    
                                    Text("\(item.count)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    
                    // Insights
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Insights")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            insightRow(
                                icon: "calendar",
                                text: "You've been journaling for \(journalingDays) days"
                            )
                            
                            insightRow(
                                icon: "star.fill",
                                text: "\(favoriteCount) entries are marked as favorites"
                            )
                            
                            if let mostActiveDay = mostActiveWeekday {
                                insightRow(
                                    icon: "chart.bar.fill",
                                    text: "You write most on \(mostActiveDay)s"
                                )
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Your Stats")
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
    
    private var journalingDays: Int {
        guard let firstEntry = gratitudeStore.entries.last?.date else { return 0 }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: firstEntry, to: Date()).day ?? 0
    }
    
    private var favoriteCount: Int {
        gratitudeStore.entries.filter { $0.isFavorite }.count
    }
    
    private var mostActiveWeekday: String? {
        let maxEntry = entriesByWeekday.max { $0.count < $1.count }
        return maxEntry?.weekday
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
    
    private func insightRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}
