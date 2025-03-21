import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), stat: 0.0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), stat: 0.0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .second, value: 10, to: currentDate)!
        
        // Get the API key from UserDefaults
        let apiKey = UserDefaults.standard.string(forKey: "gorgiasApiKey") ?? ""
        
        // TODO: Implement actual Gorgias API call
        // For now, we'll just simulate some data
        let stat = Double.random(in: 0...100)
        
        let entry = SimpleEntry(date: currentDate, stat: stat)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let stat: Double
}

struct VibeWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Gorgias Stats")
                .font(.caption)
            
            Text(String(format: "%.1f", entry.stat))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.blue)
            
            Text(entry.date.formatted(.dateTime.hour().minute().second()))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

@main
struct VibeWidget: Widget {
    let kind: String = "VibeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VibeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Gorgias Statistics")
        .description("Shows current Gorgias statistics.")
        .supportedFamilies([.systemSmall])
    }
} 