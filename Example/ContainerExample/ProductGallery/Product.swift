import Foundation

struct Product: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let imageUrl: URL
    let orderNumber: Int
    let quantity: Int
}
