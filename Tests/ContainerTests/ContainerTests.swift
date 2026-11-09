import Container
import Observation
import SwiftUI
import Testing

// MARK: - ScreenContainer

@MainActor
@Observable
private final class ScreenContainerTestModel {
    var value = 0
    func bump() { value += 1 }
}

private struct MappedContent: Equatable {
    let value: Int
}

@MainActor
@Test func screenContainerInvokesDisplayWithMappedContent() {
    let model = ScreenContainerTestModel()
    let view = ScreenContainer(
        model: model,
        mapContent: { MappedContent(value: $0.value) },
        display: { content in
            Text("v:\(content.value)")
        }
    )
    _ = view.body
    #expect(model.value == 0)
    model.bump()
    let mapped = MappedContent(value: model.value)
    #expect(mapped.value == 1)
    _ = view.body
}

// MARK: - Equatable fast path

@MainActor
@Test func equatableFactoryBuildsAndMapsLikeThePlainInitializer() {
    let model = ScreenContainerTestModel()
    model.bump()
    let view = ScreenContainer.equatable(
        model: model,
        mapContent: { MappedContent(value: $0.value) },
        display: { content in
            Text("v:\(content.value)")
        }
    )
    _ = view.body
    #expect(model.value == 1)
}

@MainActor
@Test func equatableDisplayComparesByContentAndIgnoresClosures() {
    let first = EquatableDisplay(content: MappedContent(value: 1)) { _ in EmptyView() }
    let sameContentDifferentClosure = EquatableDisplay(content: MappedContent(value: 1)) { _ in EmptyView() }
    let differentContent = EquatableDisplay(content: MappedContent(value: 2)) { _ in EmptyView() }

    #expect(first == sameContentDifferentClosure)
    #expect(first != differentContent)
}

// MARK: - ScreenModel + Send

@MainActor
@Observable
private final class CounterModel: ScreenModel {
    enum Action: Equatable { case increment, add(Int) }
    var value = 0
    private(set) var received: [Action] = []

    func send(_ action: Action) {
        received.append(action)
        switch action {
        case .increment: value += 1
        case .add(let amount): value += amount
        }
    }
}

private enum ChildAction { case tapped }

@MainActor
@Test func sendDeliversActionsToTheModel() {
    let model = CounterModel()
    let send = Send(model)
    send(.increment)
    send(.add(5))
    #expect(model.value == 6)
    #expect(model.received == [.increment, .add(5)])
}

@MainActor
@Test func mappedSendWrapsChildActions() {
    let model = CounterModel()
    let child: Send<ChildAction> = Send(model).map { _ in .add(10) }
    child(.tapped)
    #expect(model.value == 10)
}

@MainActor
@Test func sendEqualityTracksTheOwner() {
    let model = CounterModel()
    let other = CounterModel()
    #expect(Send(model) == Send(model))
    #expect(Send(model) != Send(other))

    let closure = Send<CounterModel.Action> { _ in }
    #expect(closure == closure)
    #expect(closure != Send<CounterModel.Action> { _ in })
}

@MainActor
@Test func closureSendForPreviews() {
    var log: [CounterModel.Action] = []
    let send = Send<CounterModel.Action> { log.append($0) }
    send(.increment)
    Send<CounterModel.Action>.ignoring(.increment)
    #expect(log == [.increment])
}

@MainActor
@Test func actionInitializerGivesDisplayContentAndSend() {
    let model = CounterModel()
    var captured: Send<CounterModel.Action>?
    let view = ScreenContainer(model: model, mapContent: { MappedContent(value: $0.value) }) { content, send in
        let _ = { captured = send }()
        Text("v:\(content.value)")
    }
    _ = view.body
    captured?(.increment)
    #expect(model.value == 1)
}

@MainActor
@Test func actionableContentEqualityChecksContentAndOwner() {
    let model = CounterModel()
    let other = CounterModel()
    let base = ActionableContent(content: MappedContent(value: 1), send: Send(model))

    #expect(base == ActionableContent(content: MappedContent(value: 1), send: Send(model)))
    #expect(base != ActionableContent(content: MappedContent(value: 2), send: Send(model)))
    // Same content from a different model must still re-render.
    #expect(base != ActionableContent(content: MappedContent(value: 1), send: Send(other)))
}

@MainActor
@Test func equatableActionFactoryBuilds() {
    let model = CounterModel()
    let view = ScreenContainer.equatable(model: model, mapContent: { MappedContent(value: $0.value) }) { content, send in
        Button("v:\(content.value)") { send(.increment) }
    }
    _ = view.body
    #expect(model.value == 0)
}
