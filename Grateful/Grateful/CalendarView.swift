//
//  CalendarView.swift
//  Grateful
//
//  Created by Esther Ramos on 13/01/26.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var gratitudeStore: GratitudeStore
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationView {
            VStack {
                // Month picker
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                
                // Entries for selected date
                let entries = gratitudeStore.entriesForDate(selectedDate)
                
                if entries.isEmpty {
                    emptyStateView
                        .padding()
                } else {
                    entriesListView(entries: entries)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Calendar")
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
    
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No entries for this date")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Select another date or add an entry today")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private func entriesListView(entries: [GratitudeEntry]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Entries for \(selectedDate, style: .date)")
                .font(.headline)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(entries) { entry in
                        GratitudeCard(entry: entry)
                    }
                }
            }
        }
    }
}
