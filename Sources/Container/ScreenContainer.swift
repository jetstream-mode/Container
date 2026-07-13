import Observation
import SwiftUI

/// Wires an observable **model** through a pure **content** mapper into a **display** view.
///
/// The unidirectional contract each closure is expected to honor:
/// - `mapContent` is a **pure projection** of the model: no side effects, no async
///   work, no mutation. It runs on every body evaluation, so it should also be cheap.
/// - `display` lays out UI from the **content value only** and should not capture the
///   model. Actions belong on the model, invoked from lifecycle modifiers on the
///   surrounding screen (`.task`, `.refreshable`) or from values content carries
///   deliberately.
///
/// Observation: reading model properties inside `mapContent` during body evaluation is
/// what subscribes this view — when those properties change, the container re-renders
/// (model → content → display). No property wrapper is required for that; the model is
/// held as a plain constant.
public struct ScreenContainer<Model, Content, DisplayView: View>: View
where Model: AnyObject, Model: Observation.Observable {
    private let model: Model
    private let mapContent: (Model) -> Content
    private let display: (Content) -> DisplayView

    /// - Parameters:
    ///   - model: The screen's `@Observable` model; owns state, dependencies, and async work.
    ///   - mapContent: Pure, synchronous projection from model state to renderable content.
    ///   - display: Builds the view tree from the content value alone.
    public init(
        model: Model,
        mapContent: @escaping (Model) -> Content,
        @ViewBuilder display: @escaping (Content) -> DisplayView
    ) {
        self.model = model
        self.mapContent = mapContent
        self.display = display
    }

    public var body: some View {
        display(mapContent(model))
    }
}
