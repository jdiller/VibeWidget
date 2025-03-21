//
//  VibeWidgetApp.swift
//  VibeWidget
//
//  Created by Jason Diller on 2025-03-21.
//

import SwiftUI

@main
struct VibeWidgetApp: App {
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var statsManager = StatsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsManager)
                .environmentObject(statsManager)
                .frame(minWidth: 250, minHeight: 150)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        Settings {
            SettingsView()
                .environmentObject(settingsManager)
        }
    }
}

class SettingsManager: ObservableObject {
    @Published var email: String = ""
    @Published var apiKey: String = ""
    @Published var subdomain: String = ""
    @Published var tempEmail: String = ""
    @Published var tempApiKey: String = ""
    @Published var tempSubdomain: String = ""
    @Published var isEditing: Bool = false
    
    init() {
        if let credentials = KeychainManager.shared.getCredentials() {
            self.email = credentials.email ?? ""
            self.apiKey = credentials.apiKey ?? ""
            self.subdomain = credentials.subdomain ?? ""
            self.tempEmail = self.email
            self.tempApiKey = self.apiKey
            self.tempSubdomain = self.subdomain
        }
    }
    
    func saveChanges() -> Bool {
        if KeychainManager.shared.saveCredentials(email: tempEmail, apiKey: tempApiKey, subdomain: tempSubdomain) {
            email = tempEmail
            apiKey = tempApiKey
            subdomain = tempSubdomain
            isEditing = false
            return true
        }
        return false
    }
    
    func cancelChanges() {
        tempEmail = email
        tempApiKey = apiKey
        tempSubdomain = subdomain
        isEditing = false
    }
    
    func startEditing() {
        isEditing = true
    }
}

class StatsManager: ObservableObject {
    @Published var p50Time: String = "Loading..."
    @Published var p90Time: String = "Loading..."
    @Published var createdCount: String = "Loading..."
    @Published var repliedCount: String = "Loading..."
    @Published var closedCount: String = "Loading..."
    @Published var lastUpdated: Date?
    @Published var error: String?
    private var timer: Timer?
    
    init() {
        startFetching()
    }
    
    func startFetching() {
        fetchStats()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.fetchStats()
        }
    }
    
    func stopFetching() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTimeInSeconds(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            return "\(hours)h \(minutes)m"
        }
    }
    
    private func fetchStats() {
        Task {
            do {
                guard let credentials = KeychainManager.shared.getCredentials(),
                      let email = credentials.email,
                      let apiKey = credentials.apiKey,
                      let subdomain = credentials.subdomain else {
                    await MainActor.run {
                        self.error = "Please configure your Gorgias credentials in Settings"
                    }
                    return
                }
                
                let api = GorgiasAPI(email: email, apiKey: apiKey, subdomain: subdomain)
                
                async let resolutionStats = api.fetchResolutionTime()
                async let volumeStats = api.fetchSupportVolume()
                
                let (resolution, volume) = try await (resolutionStats, volumeStats)
                
                await MainActor.run {
                    self.p50Time = "\(resolution.p50)"
                    self.p90Time = "\(resolution.p90)"
                    self.createdCount = "\(volume.created)"
                    self.repliedCount = "\(volume.replied)"
                    self.closedCount = "\(volume.closed)"
                    self.lastUpdated = Date()
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = "Error fetching stats: \(error.localizedDescription)"
                }
            }
        }
    }
}
