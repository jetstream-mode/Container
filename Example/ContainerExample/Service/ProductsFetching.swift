import Foundation

/// Async API for loading products (mock: ``MockProductsService``).
protocol ProductsFetching: Sendable {
    func getProducts() async throws -> [Product]
}
