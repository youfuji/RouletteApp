import SwiftUI
import Combine

@MainActor
class RouletteViewModel: ObservableObject {
    @Published var candidates: [Candidate] = []
    @Published var opinions: [Opinion] = []
    @Published var inputText: String = ""
    @Published var rotationAngle: Double = 0
    @Published var selectedResult: String = "スタートボタンを押してね"
    @Published var isSpinning: Bool = false
    @Published var isAnalyzing: Bool = false
    
    private let aiService: AIServiceProtocol
    
    init(aiService: AIServiceProtocol = MockAIService()) {
        self.aiService = aiService
        
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
    
    // MARK: - AI Analysis
    func analyzeOpinions() async {
        guard !candidates.isEmpty else { return }
        isAnalyzing = true
        
        do {
            let candidateNames = candidates.map { $0.name }
            let opinionTexts = opinions.map { "\($0.author): \($0.text)" }
            
            let result = try await aiService.analyze(candidates: candidateNames, opinions: opinionTexts)
            
            // Apply weights
            for (name, weight) in result.weights {
                if let index = candidates.firstIndex(where: { $0.name == name }) {
                    candidates[index].weight = weight
                    candidates[index].aiReason = result.reason
                }
            }
        } catch {
            print("AI Analysis Error: \(error)")
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
        // Normalize current rotation to 0-360
        let currentRotation = rotationAngle.truncatingRemainder(dividingBy: 360)
        
        // Calculate the angle at the pointer (top, 270 degrees in SwiftUI coordinate system if 0 is right)
        // However, standard math: 0 is right, 90 is bottom, 180 is left, 270 is top.
        // SwiftUI default: 0 is right.
        // To find what's at the TOP (270 deg / -90 deg), we need to account for rotation.
        // Let's stick to the previous logic which seemed to work, or improve it for weighted.
        
        // Weighted Logic:
        // 1. Calculate total weight
        let totalWeight = candidates.reduce(0) { $0 + $1.weight }
        
        // 2. Determine where the pointer lands in the "cumulative weight" distribution.
        // The wheel rotates CLOCKWISE. The pointer is fixed at the TOP.
        // Effectively, we are sampling a point on the wheel.
        
        // Let's simplify: The visual rotation is `rotationAngle`.
        // The pointer is at -90 degrees (Top) relative to the circle's 0 (Right).
        // The effective angle on the wheel that is touching the pointer is:
        // (PointerAngle - RotationAngle) normalized.
        
        let pointerAngle = 270.0 // Top
        let effectiveAngle = (pointerAngle - currentRotation).truncatingRemainder(dividingBy: 360)
        let normalizedAngle = effectiveAngle < 0 ? effectiveAngle + 360 : effectiveAngle
        
        // 3. Find which candidate covers this angle
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
