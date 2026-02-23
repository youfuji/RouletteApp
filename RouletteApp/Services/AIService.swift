import Foundation

// MARK: - Analysis Result

struct AnalysisResult: Codable {
    let weights: [String: Double]
    let reasons: [String]
    
    // Backward compatibility
    var reason: String {
        reasons.joined(separator: "\n")
    }
}

// MARK: - Protocol

protocol AIServiceProtocol: Sendable {
    func analyze(candidates: [String], opinions: [String]) async throws -> AnalysisResult
}

// MARK: - Errors

enum AIServiceError: LocalizedError {
    case noAPIKey
    case rateLimitExceeded(remaining: Int)
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "APIキーが設定されていません。\n設定画面でGemini APIキーを入力してください。"
        case .rateLimitExceeded(let remaining):
            return "本日のAI分析回数が上限に達しました。\n残り: \(remaining)回（翌日リセットされます）"
        case .networkError(let error):
            return "通信エラーが発生しました。\n\(error.localizedDescription)"
        case .invalidResponse:
            return "AIからの応答が正しく解析できませんでした。\nもう一度お試しください。"
        case .apiError(let message):
            return "APIエラー: \(message)"
        }
    }
}

// MARK: - Gemini AI Service

final class GeminiAIService: AIServiceProtocol, @unchecked Sendable {
    private let apiKey: String
    private let model = "gemini-2.0-flash"
    private let maxOutputTokens = 256
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func analyze(candidates: [String], opinions: [String]) async throws -> AnalysisResult {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)")!
        
        // Build compact prompt
        let candidateList = candidates.joined(separator: ",")
        let opinionList = opinions.isEmpty ? "なし" : opinions.joined(separator: " / ")
        
        let prompt = """
        候補: [\(candidateList)]
        意見: \(opinionList)
        
        上記の意見を分析し、各候補の適切な重みを決定してください。
        JSON形式で回答: {"weights":{"候補名":0.0〜1.0の数値},"reasons":["理由1","理由2"]}
        理由は2-3個、各20文字以内の箇条書きで。重みの合計は1.0にしてください。
        """
        
        // Build request body
        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "responseMimeType": "application/json",
                "maxOutputTokens": maxOutputTokens,
                "temperature": 0.3
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 15
        
        let (data, response) : (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AIServiceError.networkError(error)
        }
        
        // Check HTTP status
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200:
                break
            case 401, 403:
                throw AIServiceError.apiError("APIキーが無効です。設定画面で正しいキーを入力してください。")
            case 429:
                throw AIServiceError.apiError("APIレート制限に達しました。しばらく待ってからお試しください。")
            default:
                let body = String(data: data, encoding: .utf8) ?? ""
                throw AIServiceError.apiError("HTTP \(httpResponse.statusCode): \(body)")
            }
        }
        
        // Parse Gemini response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
            throw AIServiceError.invalidResponse
        }
        
        // Parse the JSON text from Gemini
        guard let resultData = text.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }
        
        do {
            let result = try JSONDecoder().decode(AnalysisResult.self, from: resultData)
            return result
        } catch {
            throw AIServiceError.invalidResponse
        }
    }
}

// MARK: - Mock AI Service (for testing / no API key)

final class MockAIService: AIServiceProtocol, @unchecked Sendable {
    func analyze(candidates: [String], opinions: [String]) async throws -> AnalysisResult {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        // Return dummy data with equal weights
        var weights: [String: Double] = [:]
        let count = Double(candidates.count)
        for candidate in candidates {
            weights[candidate] = 1.0 / count
        }
        
        return AnalysisResult(
            weights: weights,
            reasons: [
                "モックAIによる均等分析",
                "実際のAPIには未接続",
                "設定からGemini APIキーを入力してください"
            ]
        )
    }
}
