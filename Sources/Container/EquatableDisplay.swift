import SwiftUI

/// Wraps a display view so SwiftUI can skip re-evaluating it when consecutive content
/// values compare equal. Equality deliberately ignores the `display` closure: within a
/// single ``ScreenContainer`` it is stable for the container's lifetime.
public struct EquatableDisplay<Content: Equatable, DisplayView: View>: View, Equatable {
    let content: Content
    let display: (Content) -> DisplayView

    public init(content: Content, @ViewBuilder display: @escaping (Content) -> DisplayView) {
        self.content = content
        self.display = display
    }

    // nonisolated: `View` is @MainActor in current SDKs, but Equatable's requirement
    // is nonisolated — and equality only reads value-typed parameters anyway.
    public nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.content == rhs.content
    }

    public var body: some View {
        display(content)
    }
}

extension ScreenContainer {
    /// Like ``ScreenContainer/init(model:mapContent:display:)``, but skips re-evaluating
    /// the display when a model change maps to **equal content** — the mapper still runs,
    /// the layout pass doesn't. This also makes the pattern's premise checkable by the
    /// compiler: content is a value snapshot, and `Equatable` is what that buys you.
    ///
    /// Prefer this when `Content` can conform to `Equatable` cheaply (value fields only).
    public static func equatable<D: View>(
        model: Model,
        mapContent: @escaping (Model) -> Content,
        @ViewBuilder display: @escaping (Content) -> D
    ) -> ScreenContainer where Content: Equatable, DisplayView == EquatableView<EquatableDisplay<Content, D>> {
        ScreenContainer(model: model, mapContent: mapContent) { content in
            EquatableDisplay(content: content, display: display).equatable()
        }
    }
}
