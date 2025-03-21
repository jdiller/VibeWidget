import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.example.vibewidget"
    private let apiKeyAccount = "gorgiasApiKey"
    private let emailAccount = "gorgiasEmail"
    private let subdomainAccount = "gorgiasSubdomain"
    
    private init() {}
    
    func saveCredentials(email: String, apiKey: String, subdomain: String) -> Bool {
        // Save email
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: emailAccount,
            kSecValueData as String: email.data(using: .utf8)!
        ]
        
        // Save API key
        let apiKeyQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: apiKeyAccount,
            kSecValueData as String: apiKey.data(using: .utf8)!
        ]
        
        // Save subdomain
        let subdomainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: subdomainAccount,
            kSecValueData as String: subdomain.data(using: .utf8)!
        ]
        
        // First try to delete any existing items
        SecItemDelete(emailQuery as CFDictionary)
        SecItemDelete(apiKeyQuery as CFDictionary)
        SecItemDelete(subdomainQuery as CFDictionary)
        
        // Then add the new items
        let emailStatus = SecItemAdd(emailQuery as CFDictionary, nil)
        let apiKeyStatus = SecItemAdd(apiKeyQuery as CFDictionary, nil)
        let subdomainStatus = SecItemAdd(subdomainQuery as CFDictionary, nil)
        
        return emailStatus == errSecSuccess && apiKeyStatus == errSecSuccess && subdomainStatus == errSecSuccess
    }
    
    func getCredentials() -> (email: String?, apiKey: String?, subdomain: String?)? {
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: emailAccount,
            kSecReturnData as String: true
        ]
        
        let apiKeyQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: apiKeyAccount,
            kSecReturnData as String: true
        ]
        
        let subdomainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: subdomainAccount,
            kSecReturnData as String: true
        ]
        
        var emailResult: AnyObject?
        var apiKeyResult: AnyObject?
        var subdomainResult: AnyObject?
        
        let emailStatus = SecItemCopyMatching(emailQuery as CFDictionary, &emailResult)
        let apiKeyStatus = SecItemCopyMatching(apiKeyQuery as CFDictionary, &apiKeyResult)
        let subdomainStatus = SecItemCopyMatching(subdomainQuery as CFDictionary, &subdomainResult)
        
        guard emailStatus == errSecSuccess,
              apiKeyStatus == errSecSuccess,
              subdomainStatus == errSecSuccess,
              let emailData = emailResult as? Data,
              let apiKeyData = apiKeyResult as? Data,
              let subdomainData = subdomainResult as? Data,
              let email = String(data: emailData, encoding: .utf8),
              let apiKey = String(data: apiKeyData, encoding: .utf8),
              let subdomain = String(data: subdomainData, encoding: .utf8) else {
            return nil
        }
        
        return (email: email, apiKey: apiKey, subdomain: subdomain)
    }
} 