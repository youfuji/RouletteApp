import SwiftUI

struct Candidate: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var color: Color
    var weight: Double = 1.0
    var aiReason: String?
}
