import Foundation

struct GorgiasResponse: Codable {
    let data: ResolutionTimeData
    let meta: MetaData
}

struct SupportVolumeResponse: Codable {
    let data: SupportVolumeData
    let meta: MetaData
}

struct ResolutionTimeData: Codable {
    let label: String
    let legend: Legend
    let data: DataPoints
}

struct SupportVolumeData: Codable {
    let label: String
    let legend: Legend
    let data: SupportVolumeDataPoints
}

struct Legend: Codable {
    let axes: Axes
}

struct Axes: Codable {
    let x: String
    let y: String
}

struct DataPoints: Codable {
    let axes: DataAxes
    let lines: [Line]
}

struct SupportVolumeDataPoints: Codable {
    let axes: DataAxes
    let lines: [SupportVolumeLine]
}

struct DataAxes: Codable {
    let x: [Int]
    let y: [Int]
}

struct Line: Codable {
    let name: String
    let data: [Int]
}

struct SupportVolumeLine: Codable {
    let name: String
    let data: [Int]
}

struct MetaData: Codable {
    let end_datetime: String
    let previous_end_datetime: String
    let previous_start_datetime: String
    let start_datetime: String
}

struct ResolutionTimeStats {
    let p50: Int
    let p90: Int
}

struct SupportVolumeStats {
    let created: Int
    let replied: Int
    let closed: Int
}

class GorgiasAPI {
    private let baseURL: String
    private let email: String
    private let apiKey: String
    
    init(email: String, apiKey: String, subdomain: String) {
        self.email = email
        self.apiKey = apiKey
        self.baseURL = "https://\(subdomain).gorgias.com/api"
        print("Initialized GorgiasAPI with baseURL: \(baseURL)")
    }
    
    private func getAuthHeader() -> String {
        let authString = "\(email):\(apiKey)"
        guard let authData = authString.data(using: .utf8) else {
            return ""
        }
        let base64Auth = authData.base64EncodedString()
        return "Basic \(base64Auth)"
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
    
    private func makeRequest(endpoint: String, startDate: String, endDate: String) async throws -> Data {
        guard let url = URL(string: endpoint) else {
            print("❌ Failed to create URL")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(getAuthHeader(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "start_datetime": startDate,
            "end_datetime": endDate
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("Request body: \(jsonString)")
            }
        } catch {
            print("❌ Failed to serialize request body: \(error)")
            throw error
        }
        
        print("\nRequest headers:")
        request.allHTTPHeaderFields?.forEach { key, value in
            if key == "Authorization" {
                print("\(key): Basic [REDACTED]")
            } else {
                print("\(key): \(value)")
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Response is not an HTTP response")
            throw URLError(.badServerResponse)
        }
        
        print("\nResponse status code: \(httpResponse.statusCode)")
        print("Response headers:")
        httpResponse.allHeaderFields.forEach { key, value in
            print("\(key): \(value)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("\nResponse body: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Bad response status code: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
    func fetchResolutionTime() async throws -> ResolutionTimeStats {
        let endpoint = "\(baseURL)/stats/resolution-time"
        print("\n=== Making API Request ===")
        print("Endpoint: \(endpoint)")
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .hour, value: -24, to: endDate)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        print("Date range: \(startDateString) to \(endDateString)")
        
        let data = try await makeRequest(endpoint: endpoint, startDate: startDateString, endDate: endDateString)
        let decoder = JSONDecoder()
        let result = try decoder.decode(GorgiasResponse.self, from: data)
        
        guard let p50Line = result.data.data.lines.first(where: { $0.name == "50%" }),
              let p90Line = result.data.data.lines.first(where: { $0.name == "90%" }),
              let p50Value = p50Line.data.last,
              let p90Value = p90Line.data.last else {
            throw URLError(.badServerResponse)
        }
        
        print("\nSuccessfully decoded response. P50: \(formatTimeInSeconds(p50Value)), P90: \(formatTimeInSeconds(p90Value))")
        return ResolutionTimeStats(p50: p50Value, p90: p90Value)
    }
    
    func fetchSupportVolume() async throws -> SupportVolumeStats {
        let endpoint = "\(baseURL)/stats/support-volume"
        print("\n=== Making API Request ===")
        print("Endpoint: \(endpoint)")
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .hour, value: -24, to: endDate)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        print("Date range: \(startDateString) to \(endDateString)")
        
        let data = try await makeRequest(endpoint: endpoint, startDate: startDateString, endDate: endDateString)
        let decoder = JSONDecoder()
        let result = try decoder.decode(SupportVolumeResponse.self, from: data)
        
        guard let createdLine = result.data.data.lines.first(where: { $0.name == "created" }),
              let repliedLine = result.data.data.lines.first(where: { $0.name == "replied" }),
              let closedLine = result.data.data.lines.first(where: { $0.name == "closed" }),
              let createdValue = createdLine.data.last,
              let repliedValue = repliedLine.data.last,
              let closedValue = closedLine.data.last else {
            throw URLError(.badServerResponse)
        }
        
        print("\nSuccessfully decoded response. Created: \(createdValue), Replied: \(repliedValue), Closed: \(closedValue)")
        return SupportVolumeStats(created: createdValue, replied: repliedValue, closed: closedValue)
    }
} 