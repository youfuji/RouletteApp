import Foundation

struct AnalysisResult: Codable {
    let weights: [String: Double]
    let reason: String
}

protocol AIServiceProtocol {
    func analyze(candidates: [String], opinions: [String]) async throws -> AnalysisResult
}

// Dummy implementation for MVP/Testing
class MockAIService: AIServiceProtocol {
    func analyze(candidates: [String], opinions: [String]) async throws -> AnalysisResult {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        // Return dummy data
        var weights: [String: Double] = [:]
        let count = Double(candidates.count)
        for candidate in candidates {
            weights[candidate] = 1.0 / count // Equal weights for now
        }
        
        return AnalysisResult(
            weights: weights,
            reason: "これはモックAIによる分析結果です。まだ実際のAPIには接続されていません。"
        )
    }
}
