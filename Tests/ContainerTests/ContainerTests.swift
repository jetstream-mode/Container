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
