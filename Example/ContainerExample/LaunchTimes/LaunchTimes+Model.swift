import Foundation
import Observation

enum LaunchTimes {}

extension LaunchTimes {
    struct State {
        var launches: [LaunchSummary] = []
        var isLoading = false
        var errorMessage: String?
    }

    /// Screen data lives in ``state``.
    @MainActor
    @Observable
    final class Model {
        var state = State()

        private let fetcher: LaunchesFetching

        init(fetcher: LaunchesFetching) {
            self.fetcher = fetcher
        }

        func loadLaunches() async {
            guard !state.isLoading else { return }
            state.isLoading = true
            state.errorMessage = nil
            defer { state.isLoading = false }

            do {
                let fetched = try await fetcher.fetchLaunches()
                state.launches = fetched
            } catch {
                state.errorMessage = error.localizedDescription
            }
        }
    }
}
