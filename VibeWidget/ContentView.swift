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
        VStack(spacing: 20) {
            if let error = statsManager.error {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else {
                VStack(spacing: 12) {
                    Text(statsManager.p50Time)
                        .font(.system(size: 24, weight: .medium))
                    Text(statsManager.p90Time)
                        .font(.system(size: 24, weight: .medium))
                }
                
                if let lastUpdated = statsManager.lastUpdated {
                    Text("Last updated: \(lastUpdated.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
        .environmentObject(StatsManager())
}
