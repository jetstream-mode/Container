import Foundation

/// Summary of a launch for UI lists.
struct LaunchSummary: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let dateUTC: Date
}

/// Async API for loading launches (live: ``SpaceXLaunchesService``; previews/tests: inject a mock).
protocol LaunchesFetching: Sendable {
    func fetchLaunches() async throws -> [LaunchSummary]
}
