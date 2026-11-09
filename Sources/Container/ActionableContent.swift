/// Content paired with the ``Send`` that came with it.
///
/// Used by the `equatable` factory for ``ScreenModel`` screens so the skip-render check
/// compares both: equal content from a *different* model still re-renders, and the display
/// never keeps calling into a model that has been replaced.
public struct ActionableContent<Content, Action> {
    public let content: Content
    public let send: Send<Action>

    public init(content: Content, send: Send<Action>) {
        self.content = content
        self.send = send
    }
}

extension ActionableContent: Equatable where Content: Equatable {}
