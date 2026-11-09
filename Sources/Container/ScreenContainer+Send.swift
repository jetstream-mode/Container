import SwiftUI

extension ScreenContainer where Model: ScreenModel {
    /// Wires a ``ScreenModel`` so the display gets **content down** and **a ``Send`` up**,
    /// never the model itself.
    ///
    /// ```swift
    /// ScreenContainer(model: model, mapContent: GoalList.buildContent(from:)) { content, send in
    ///     GoalList.Display(content: content, send: send)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - model: The screen's model; owns state, dependencies, async work, and action handling.
    ///   - mapContent: Pure, synchronous projection from model state to renderable content.
    ///   - display: Builds the view tree from the content value and reports intent through `send`.
    public init(
        model: Model,
        mapContent: @escaping (Model) -> Content,
        @ViewBuilder display: @escaping (Content, Send<Model.Action>) -> DisplayView
    ) {
        let send = Send(model)
        self.init(model: model, mapContent: mapContent) { content in
            display(content, send)
        }
    }

    /// Like ``init(model:mapContent:display:)-(_,_,(Content,Send<Model.Action>)->DisplayView)``,
    /// but skips re-evaluating the display when a model change maps to equal content.
    /// Equality also checks the ``Send``'s owner, so swapping in a different model always
    /// re-renders. Same tradeoffs as the plain ``equatable(model:mapContent:display:)-(_,_,(Content)->D)``:
    /// an opt-in for a measured problem, not a default.
    public static func equatable<D: View>(
        model: Model,
        mapContent: @escaping (Model) -> Content,
        @ViewBuilder display: @escaping (Content, Send<Model.Action>) -> D
    ) -> ScreenContainer
    where Content: Equatable,
          DisplayView == EquatableView<EquatableDisplay<ActionableContent<Content, Model.Action>, D>> {
        let send = Send(model)
        return ScreenContainer(model: model, mapContent: mapContent) { content in
            EquatableDisplay(content: ActionableContent(content: content, send: send)) { pair in
                display(pair.content, pair.send)
            }
            .equatable()
        }
    }
}
