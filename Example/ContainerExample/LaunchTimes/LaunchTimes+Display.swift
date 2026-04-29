import Container
import SwiftUI

extension LaunchTimes {
    /// Pull-to-refresh and initial load call ``LaunchTimes.Model``; body is driven by ``ScreenContainer`` + Observation.
    struct Screen: View {
        @Bindable private var model: Model

        init(model: Model) {
            self.model = model
        }

        var body: some View {
            ScreenContainer(
                model: model,
                mapContent: LaunchTimes.buildContent(from:),
                display: makeDisplay(content:)
            )
            .refreshable { await model.loadLaunches() }
            .task { await model.loadLaunches() }
        }

        private func makeDisplay(content: LaunchTimesContent) -> Display {
            Display(content: content)
        }
    }

    struct Display: View {
        let content: LaunchTimesContent
        @Environment(\.navRouter) private var navRouter

        var body: some View {
            List {
                if let errorMessage = content.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    ForEach(content.rows) { row in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(row.title)
                                .font(.headline)
                            Text(row.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(content.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("A") { navRouter?.push(LaunchesRoute.detailAlpha) }
                    Button("B") { navRouter?.push(LaunchesRoute.detailBeta) }
                }
            }
            .overlay {
                if content.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial.opacity(0.85))
                }
            }
        }
    }
}
