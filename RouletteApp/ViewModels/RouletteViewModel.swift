import SwiftUI
import Combine

@MainActor
class RouletteViewModel: ObservableObject {
    @Published var candidates: [Candidate] = []
    @Published var opinions: [Opinion] = []
    @Published var inputText: String = ""
    @Published var opinionText: String = ""
    @Published var opinionAuthor: String = ""
    @Published var rotationAngle: Double = 0
    @Published var selectedResult: String = "スタートボタンを押してね"
    @Published var isSpinning: Bool = false
    @Published var isAnalyzing: Bool = false
    @Published var aiReasons: [String] = []
    @Published var errorMessage: String?
    @Published var showSettings: Bool = false
    
    let apiKeyManager: APIKeyManager
    let rateLimiter: RateLimiter
    
    private var aiService: AIServiceProtocol {
        if apiKeyManager.hasAPIKey {
            return GeminiAIService(apiKey: apiKeyManager.apiKey)
        } else {
            return MockAIService()
        }
    }
    
    init(apiKeyManager: APIKeyManager? = nil, rateLimiter: RateLimiter? = nil) {
        self.apiKeyManager = apiKeyManager ?? APIKeyManager()
        self.rateLimiter = rateLimiter ?? RateLimiter()
        
        // Initial data
        addCandidate(name: "ラーメン")
        addCandidate(name: "カレー")
        addCandidate(name: "寿司")
        addCandidate(name: "パスタ")
    }
    
    // MARK: - Candidate Management
    func addCandidate(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        let hue = Double(candidates.count) * 0.15
        let color = Color(hue: hue.truncatingRemainder(dividingBy: 1.0), saturation: 0.6, brightness: 0.9)
        
        candidates.append(Candidate(name: trimmed, color: color))
        inputText = ""
    }
    
    func removeCandidate(at offsets: IndexSet) {
        candidates.remove(atOffsets: offsets)
    }
    
    // MARK: - Opinion Management
    func addOpinion() {
        let trimmedText = opinionText.trimmingCharacters(in: .whitespaces)
        let trimmedAuthor = opinionAuthor.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else { return }
        
        let author = trimmedAuthor.isEmpty ? "匿名" : trimmedAuthor
        opinions.append(Opinion(text: trimmedText, author: author))
        opinionText = ""
    }
    
    func removeOpinion(at offsets: IndexSet) {
        opinions.remove(atOffsets: offsets)
    }
    
    // MARK: - AI Analysis
    func analyzeOpinions() async {
        guard !candidates.isEmpty else { return }
        
        // Check rate limit
        guard rateLimiter.canMakeRequest else {
            errorMessage = "本日のAI分析回数が上限（\(rateLimiter.dailyLimit)回）に達しました。\n翌日にリセットされます。"
            return
        }
        
        isAnalyzing = true
        errorMessage = nil
        
        do {
            let candidateNames = candidates.map { $0.name }
            let opinionTexts = opinions.map { "\($0.author): \($0.text)" }
            
            let result = try await aiService.analyze(candidates: candidateNames, opinions: opinionTexts)
            
            // Record usage
            rateLimiter.recordUsage()
            
            // Apply weights
            for (name, weight) in result.weights {
                if let index = candidates.firstIndex(where: { $0.name == name }) {
                    candidates[index].weight = weight
                }
            }
            
            // Store reasons
            aiReasons = result.reasons
            
        } catch let error as AIServiceError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "予期せぬエラー: \(error.localizedDescription)"
        }
        
        isAnalyzing = false
    }
    
    // MARK: - Roulette Logic
    func spinRoulette() {
        guard !candidates.isEmpty, !isSpinning else { return }
        
        isSpinning = true
        selectedResult = "抽選中..."
        
        let randomAngle = Double.random(in: 0..<360)
        let totalSpin = 360.0 * 5.0 + randomAngle
        
        withAnimation(.easeOut(duration: 4.0)) {
            rotationAngle += totalSpin
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.calculateResult()
            self.isSpinning = false
        }
    }
    
    private func calculateResult() {
        let currentRotation = rotationAngle.truncatingRemainder(dividingBy: 360)
        let totalWeight = candidates.reduce(0) { $0 + $1.weight }
        
        let pointerAngle = 270.0
        let effectiveAngle = (pointerAngle - currentRotation).truncatingRemainder(dividingBy: 360)
        let normalizedAngle = effectiveAngle < 0 ? effectiveAngle + 360 : effectiveAngle
        
        var currentAngle = 0.0
        for candidate in candidates {
            let sliceAngle = 360.0 * (candidate.weight / totalWeight)
            let endAngle = currentAngle + sliceAngle
            
            if normalizedAngle >= currentAngle && normalizedAngle < endAngle {
                selectedResult = "結果: \(candidate.name)"
                return
            }
            currentAngle += sliceAngle
        }
    }
}
