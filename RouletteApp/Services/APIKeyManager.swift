import Foundation
import Combine

@MainActor
class APIKeyManager: ObservableObject {
    private static let apiKeyKey = "gemini_api_key"
    
    @Published var apiKey: String = "" {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: Self.apiKeyKey)
        }
    }
    
    var hasAPIKey: Bool {
        !apiKey.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    init() {
        self.apiKey = UserDefaults.standard.string(forKey: Self.apiKeyKey) ?? ""
    }
    
    func clearAPIKey() {
        apiKey = ""
        UserDefaults.standard.removeObject(forKey: Self.apiKeyKey)
    }
}
