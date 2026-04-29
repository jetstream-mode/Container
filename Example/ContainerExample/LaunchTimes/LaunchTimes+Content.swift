import Foundation

/// Values the Display layer needs — no action closures; loading/refresh is owned by ``LaunchTimes.Model``.
struct LaunchTimesContent {
    struct Row: Identifiable, Equatable, Sendable {
        let id: String
        let title: String
        let subtitle: String
    }

    let navigationTitle: String
    let rows: [Row]
    let isLoading: Bool
    let errorMessage: String?

    init(
        navigationTitle: String,
        rows: [Row],
        isLoading: Bool,
        errorMessage: String?
    ) {
        self.navigationTitle = navigationTitle
        self.rows = rows
        self.isLoading = isLoading
        self.errorMessage = errorMessage
    }
}

extension LaunchTimes {
    /// Pure projection from model → display content (no async hooks).
    @MainActor
    static func buildContent(from model: LaunchTimes.Model) -> LaunchTimesContent {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        let rows = model.state.launches.map { launch -> LaunchTimesContent.Row in
            LaunchTimesContent.Row(
                id: launch.id,
                title: launch.name,
                subtitle: formatter.string(from: launch.dateUTC)
            )
        }

        return LaunchTimesContent(
            navigationTitle: "Launches",
            rows: rows,
            isLoading: model.state.isLoading,
            errorMessage: model.state.errorMessage
        )
    }
}
