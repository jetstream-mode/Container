import Observation

/// A screen model that accepts user intent as values.
///
/// Conforming lets ``ScreenContainer`` hand its display a ``Send`` instead of the model,
/// which completes the one-way loop: state flows down as `Content`, intent flows up as
/// `Action`, and only the model decides what an action does.
///
/// ```swift
/// @MainActor @Observable
/// final class Model: ScreenModel {
///     enum Action { case refresh, delete(Item.ID) }
///     func send(_ action: Action) { ... }
/// }
/// ```
@MainActor
public protocol ScreenModel: AnyObject, Observation.Observable {
    /// Everything the display can ask the model to do.
    associatedtype Action

    /// Handles one action. Start async work from here with a stored `Task` the model owns,
    /// so it can be cancelled or awaited (e.g. by tests).
    func send(_ action: Action)
}
