import Foundation

class GorgiasAPI {
    private let baseURL: String
    private let email: String
    private let apiKey: String
    
    init(email: String, apiKey: String, subdomain: String) {
        self.email = email
        self.apiKey = apiKey
        self.baseURL = "https://\(subdomain).gorgias.com/api"
    }
    
    private func getAuthHeader() -> String {
        let authString = "\(email):\(apiKey)"
        guard let authData = authString.data(using: .utf8) else {
            return ""
        }
        let base64Auth = authData.base64EncodedString()
        return "Basic \(base64Auth)"
    }
    
    func fetchResolutionTime() async throws -> Double {
        let endpoint = "\(baseURL)/stats/resolution-time"
        
        // Calculate time range for last 24 hours
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .hour, value: -24, to: endDate)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create JSON request body
        let requestBody: [String: Any] = [
            "start_date": startDateString,
            "end_date": endDateString
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        struct ResolutionTimeResponse: Codable {
            let average: Double
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(ResolutionTimeResponse.self, from: data)
        return result.average
    }
} 