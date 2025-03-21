//
//  VibeWidgetStatsWidget.swift
//  VibeWidgetStatsWidget
//
//  Created by Jason Diller on 2025-03-21.
//  Copyright © 2025 gorgias. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), stats: .empty)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), stats: .empty)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        // Get the shared stats from UserDefaults
        let stats: SharedStats
        if let data = UserDefaults(suiteName: "group.com.gorgias.vibewidget")?.data(forKey: "sharedStats"),
           let decoded = try? JSONDecoder().decode(SharedStats.self, from: data) {
            stats = decoded
        } else {
            stats = .empty
        }
        
        // Create an entry with the current stats
        let entry = SimpleEntry(date: Date(), stats: stats)
        
        // Update every 10 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let stats: SharedStats
}

struct VibeWidgetStatsWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Ticket resolution times")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text("50th:")
                        .foregroundColor(.primary)
                        .frame(width: 80, alignment: .leading)
                    Text(entry.stats.p50Time)
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text("90th:")
                        .foregroundColor(.primary)
                        .frame(width: 80, alignment: .leading)
                    Text(entry.stats.p90Time)
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                }
            }
            .font(.system(size: 20))
            
            Divider()
                .padding(.vertical, 8)
            
            Text("Support volume")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text("Created:")
                        .foregroundColor(.primary)
                        .frame(width: 80, alignment: .leading)
                    Text(entry.stats.createdCount)
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text("Replied:")
                        .foregroundColor(.primary)
                        .frame(width: 80, alignment: .leading)
                    Text(entry.stats.repliedCount)
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text("Closed:")
                        .foregroundColor(.primary)
                        .frame(width: 80, alignment: .leading)
                    Text(entry.stats.closedCount)
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)
                }
            }
            .font(.system(size: 20))
            
            Text("Last updated: \(entry.stats.lastUpdated.formatted(.relative(presentation: .named)))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
    }
}

struct VibeWidgetStatsWidget: Widget {
    let kind: String = "VibeWidgetStatsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            VibeWidgetStatsWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Gorgias Stats")
        .description("Shows ticket resolution times and support volume")
        .supportedFamilies([.systemLarge])
    }
}
