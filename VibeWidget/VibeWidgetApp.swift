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
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 200, height: 150)
        
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
    @Published var currentStat: Double = 0.0
    @Published var error: String?
    private var timer: Timer?
    private var api: GorgiasAPI?
    
    init() {
        startFetching()
    }
    
    func startFetching() {
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchStats()
            }
        }
        Task {
            await fetchStats()
        }
    }
    
    private func fetchStats() async {
        guard let settingsManager = try? SettingsManager(),
              !settingsManager.apiKey.isEmpty,
              !settingsManager.email.isEmpty,
              !settingsManager.subdomain.isEmpty else {
            DispatchQueue.main.async {
                self.error = "Please configure your Gorgias credentials in Settings"
            }
            return
        }
        
        do {
            let api = GorgiasAPI(
                email: settingsManager.email,
                apiKey: settingsManager.apiKey,
                subdomain: settingsManager.subdomain
            )
            
            let resolutionTime = try await api.fetchResolutionTime()
            
            DispatchQueue.main.async {
                self.currentStat = resolutionTime
                self.error = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.error = "Failed to fetch stats: \(error.localizedDescription)"
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
