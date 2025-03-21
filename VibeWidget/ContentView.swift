//
//  ContentView.swift
//  VibeWidget
//
//  Created by Jason Diller on 2025-03-21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var statsManager: StatsManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Gorgias Statistics")
                .font(.title)
                .fontWeight(.bold)
            
            if let error = statsManager.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Text(String(format: "%.1f", statsManager.currentStat))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("Last updated: \(Date().formatted(.dateTime.hour().minute().second()))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(minWidth: 200, minHeight: 150)
    }
}

#Preview {
    ContentView()
        .environmentObject(StatsManager())
}
