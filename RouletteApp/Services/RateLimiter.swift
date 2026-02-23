import Foundation
import Combine

@MainActor
class RateLimiter: ObservableObject {
    private static let countKey = "daily_analysis_count"
    private static let dateKey = "daily_analysis_date"
    
    let dailyLimit: Int
    
    @Published private(set) var usedToday: Int = 0
    
    var remaining: Int {
        max(0, dailyLimit - usedToday)
    }
    
    var canMakeRequest: Bool {
        remaining > 0
    }
    
    init(dailyLimit: Int = 10) {
        self.dailyLimit = dailyLimit
        resetIfNewDay()
    }
    
    /// Check if we need to reset the counter (new day)
    private func resetIfNewDay() {
        let today = Self.todayString()
        let savedDate = UserDefaults.standard.string(forKey: Self.dateKey) ?? ""
        
        if savedDate != today {
            // New day — reset counter
            UserDefaults.standard.set(0, forKey: Self.countKey)
            UserDefaults.standard.set(today, forKey: Self.dateKey)
            usedToday = 0
        } else {
            usedToday = UserDefaults.standard.integer(forKey: Self.countKey)
        }
    }
    
    /// Record one API call
    func recordUsage() {
        resetIfNewDay()
        usedToday += 1
        UserDefaults.standard.set(usedToday, forKey: Self.countKey)
    }
    
    private static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
