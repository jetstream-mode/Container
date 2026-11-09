/// The only way a display reports user intent: `send(.delete(id))`.
///
/// A display holds a `Send` rather than its model, so it can render content and report
/// actions but can't read or mutate model state. Pass it (or a ``map(_:)``-ed child) to
/// subviews the same way.
///
/// Two values compare equal when they deliver to the same owner (the same model, or the
/// same closure-backed instance). That lets ``ScreenContainer/equatable(model:mapContent:display:)-(_,_,(Content,Send<Model.Action>)->D)``
/// skip unchanged renders without ever keeping a stale model's `Send` alive.
public struct Send<Action>: Equatable {
    private let identity: ObjectIdentifier
    /// Keeps the owner alive so `identity` can't be reused while this value exists.
    private let owner: AnyObject
    private let handler: @MainActor (Action) -> Void

    /// Delivers actions to `model.send(_:)`.
    @MainActor
    public init<Model: ScreenModel>(_ model: Model) where Model.Action == Action {
        self.init(identity: ObjectIdentifier(model), owner: model) { model.send($0) }
    }

    /// Delivers actions to a closure. Useful for previews and tests:
    /// `Display(content: .sample, send: Send { print($0) })`.
    public init(_ handler: @escaping @MainActor (Action) -> Void) {
        let token = Token()
        self.init(identity: ObjectIdentifier(token), owner: token, handler: handler)
    }

    private init(identity: ObjectIdentifier, owner: AnyObject, handler: @escaping @MainActor (Action) -> Void) {
        self.identity = identity
        self.owner = owner
        self.handler = handler
    }

    /// A `Send` that drops every action, for static previews.
    public static var ignoring: Send { Send { _ in } }

    @MainActor
    public func callAsFunction(_ action: Action) {
        handler(action)
    }

    /// A `Send` for a child view that speaks its own action type, wrapped into this one's.
    /// Keeps the same owner, so equality still tracks the model.
    ///
    /// ```swift
    /// LeadEditor.Display(content: content.lead, send: send.map(Action.lead))
    /// ```
    @MainActor
    public func map<Child>(_ transform: @escaping @MainActor (Child) -> Action) -> Send<Child> {
        let handler = self.handler
        return Send<Child>(identity: identity, owner: owner) { handler(transform($0)) }
    }

    public static func == (lhs: Send, rhs: Send) -> Bool {
        lhs.identity == rhs.identity
    }

    private final class Token {}
}
