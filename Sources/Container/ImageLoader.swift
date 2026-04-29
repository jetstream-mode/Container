import Foundation

/// Loads raw image bytes for a URL (e.g. JPEG/PNG). The default implementation is ``URLSessionImageLoader``.
public protocol ImageLoader: Sendable {
    func load(from url: URL) async throws -> Data
}
