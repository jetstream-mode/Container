import Foundation

/// Default ``ImageLoader`` implementation using `URLSession`.
public struct URLSessionImageLoader: ImageLoader {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func load(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
