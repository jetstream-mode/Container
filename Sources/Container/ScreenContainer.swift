import Observation
import SwiftUI

/// Wires an observable **model** through a pure **content** mapper into a **display** view.
/// The display layer should only lay out UI from the content value; the model handles state and async work.
public struct ScreenContainer<Model, Content, DisplayView: View>: View
where Model: AnyObject, Model: Observation.Observable {
    @Bindable private var model: Model
    private let mapContent: (Model) -> Content
    private let display: (Content) -> DisplayView

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
