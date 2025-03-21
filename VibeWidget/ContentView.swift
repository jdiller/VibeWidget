//
//  ContentView.swift
//  VibeWidget
//
//  Created by Jason Diller on 2025-03-21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var statsManager: StatsManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Ticket resolution times")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let error = statsManager.error {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else {
                VStack(spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("50th:")
                            .foregroundColor(.primary)
                            .frame(width: 50, alignment: .leading)
                        Text(statsManager.p50Time)
                            .foregroundColor(.secondary)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("90th:")
                            .foregroundColor(.primary)
                            .frame(width: 50, alignment: .leading)
                        Text(statsManager.p90Time)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.system(size: 20))
                
                Divider()
                    .padding(.vertical, 8)
                
                Text("Support volume")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("Created:")
                            .foregroundColor(.primary)
                            .frame(width: 50, alignment: .leading)
                        Text(statsManager.createdCount)
                            .foregroundColor(.secondary)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("Replied:")
                            .foregroundColor(.primary)
                            .frame(width: 50, alignment: .leading)
                        Text(statsManager.repliedCount)
                            .foregroundColor(.secondary)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("Closed:")
                            .foregroundColor(.primary)
                            .frame(width: 50, alignment: .leading)
                        Text(statsManager.closedCount)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.system(size: 20))
                
                if let lastUpdated = statsManager.lastUpdated {
                    Text("Last updated: \(lastUpdated.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .frame(width: 250)
        .background(Color(.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
        .environmentObject(StatsManager())
}
