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
    @StateObject private var statsManager: StatsManager
    
    init() {
        let settings = SettingsManager()
        _settingsManager = StateObject(wrappedValue: settings)
        _statsManager = StateObject(wrappedValue: StatsManager(settingsManager: settings))
    }
    
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
    private let settingsManager: SettingsManager
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        startFetching()
    }
    
    func startFetching() {
        Task {
            await fetchStats()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchStats()
            }
        }
    }
    
    func stopFetching() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    @MainActor
    private func fetchStats() async {
        let email = settingsManager.email
        let apiKey = settingsManager.apiKey
        let subdomain = settingsManager.subdomain
        
        if email.isEmpty || apiKey.isEmpty || subdomain.isEmpty {
            error = "Please configure your credentials in Settings"
            return
        }
        
        do {
            let api = GorgiasAPI(email: email, apiKey: apiKey, subdomain: subdomain)
            
            // Fetch resolution time
            let resolutionTime = try await api.fetchResolutionTime()
            p50Time = formatTime(Double(resolutionTime.p50))
            p90Time = formatTime(Double(resolutionTime.p90))
            
            // Fetch support volume
            let supportVolume = try await api.fetchSupportVolume()
            createdCount = "\(supportVolume.created)"
            repliedCount = "\(supportVolume.replied)"
            closedCount = "\(supportVolume.closed)"
            
            lastUpdated = Date()
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
