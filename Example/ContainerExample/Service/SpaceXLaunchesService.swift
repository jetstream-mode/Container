import Foundation

/// Loads past launches from SpaceX public API (v4).
struct SpaceXLaunchesService: LaunchesFetching {
    /// Session that does not use the shared HTTP cache, so every fetch hits the network with a full response body (no `304` + empty body in proxies).
    private static let networkOnlySession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()

    private static let launchesAPIURL: URL = {
        let string = "https://api.spacexdata.com/v4/launches"
        guard let url = URL(string: string) else {
            preconditionFailure("Invalid SpaceX launches URL string: \(string)")
        }
        return url
    }()

    private let session: URLSession
    private let url: URL

    init(session: URLSession = Self.networkOnlySession) {
        self.session = session
        self.url = Self.launchesAPIURL
    }

    func fetchLaunches() async throws -> [LaunchSummary] {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let dtos = try JSONDecoder().decode([SpaceXLaunchDTO].self, from: data)
        return dtos
            .compactMap(\.summary)
            .sorted { $0.dateUTC > $1.dateUTC }
    }
}

private struct SpaceXLaunchDTO: Decodable {
    let id: String
    let name: String
    let dateUTC: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case dateUTC = "date_utc"
    }

    var summary: LaunchSummary? {
        guard let date = Self.parseSpaceXDate(dateUTC) else { return nil }
        return LaunchSummary(id: id, name: name, dateUTC: date)
    }

    private static func parseSpaceXDate(_ string: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = fractional.date(from: string) { return d }
        let basic = ISO8601DateFormatter()
        basic.formatOptions = [.withInternetDateTime]
        return basic.date(from: string)
    }
}
