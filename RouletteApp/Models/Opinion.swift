import Foundation

struct Opinion: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var author: String
}
