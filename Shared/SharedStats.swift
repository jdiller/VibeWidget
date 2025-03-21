import Foundation

public struct SharedStats: Codable {
    public let p50Time: String
    public let p90Time: String
    public let createdCount: String
    public let repliedCount: String
    public let closedCount: String
    public let lastUpdated: Date
    
    public static let empty = SharedStats(
        p50Time: "Loading...",
        p90Time: "Loading...",
        createdCount: "Loading...",
        repliedCount: "Loading...",
        closedCount: "Loading...",
        lastUpdated: Date()
    )
    
    public init(p50Time: String, p90Time: String, createdCount: String, repliedCount: String, closedCount: String, lastUpdated: Date) {
        self.p50Time = p50Time
        self.p90Time = p90Time
        self.createdCount = createdCount
        self.repliedCount = repliedCount
        self.closedCount = closedCount
        self.lastUpdated = lastUpdated
    }
} 