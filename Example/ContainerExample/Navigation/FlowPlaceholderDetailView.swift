import SwiftUI

/// Shared stub for proving per-flow `NavigationStack` + deep links; no feature logic.
struct FlowPlaceholderDetailView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.weight(.semibold))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
