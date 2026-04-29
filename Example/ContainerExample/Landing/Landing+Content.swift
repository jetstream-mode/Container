import Foundation

/// Values the landing display needs — hero data is loaded by ``Landing.Model``.
struct LandingScreenContent {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let heroImageData: Data?
    let isHeroImageLoading: Bool
}

extension Landing {
    @MainActor
    static func buildContent(from model: Model) -> LandingScreenContent {
        LandingScreenContent(
            title: "Container",
            subtitle: "Three-layer pattern example",
            buttonTitle: "Launch times",
            heroImageData: model.state.heroImageData,
            isHeroImageLoading: model.state.isHeroImageLoading
        )
    }
}
