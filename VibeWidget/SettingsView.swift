import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Gorgias API Settings")) {
                TextField("Email", text: $settingsManager.tempEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!settingsManager.isEditing)
                    .textContentType(.emailAddress)
                
                SecureField("API Key", text: $settingsManager.tempApiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!settingsManager.isEditing)
                
                HStack {
                    TextField("Subdomain", text: $settingsManager.tempSubdomain)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!settingsManager.isEditing)
                    
                    Text(".gorgias.com")
                        .foregroundColor(.secondary)
                }
                
                Text("Enter your Gorgias email, API key, and subdomain to enable statistics fetching")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if settingsManager.isEditing {
                    HStack {
                        Button("Save") {
                            if !settingsManager.saveChanges() {
                                errorMessage = "Failed to save credentials"
                                showingError = true
                            }
                        }
                        .keyboardShortcut(.return)
                        
                        Button("Cancel") {
                            settingsManager.cancelChanges()
                        }
                    }
                } else {
                    Button("Edit") {
                        settingsManager.startEditing()
                    }
                }
            }
            
            Section(header: Text("About")) {
                Text("Vibe Widget")
                    .font(.headline)
                Text("Version 1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
} 