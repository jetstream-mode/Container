import Container
import Foundation
import Observation

extension Landing {
    struct Navigation: Equatable {
        var showLaunchTimes = false
    }

    struct State: Equatable {
        var heroImageData: Data?
        var isHeroImageLoading = false
    }

    @MainActor
    @Observable
    final class Model {
        private static let heroImageURLString = "https://picsum.photos/id/29/1200/600"

        static var heroImageURL: URL {
            guard let url = URL(string: heroImageURLString) else {
                preconditionFailure("Invalid hero image URL string: \(heroImageURLString)")
            }
            return url
        }

        var navigation = Navigation()
        var state = State()

        private let imageLoader: any ImageLoader

        init(imageLoader: any ImageLoader = URLSessionImageLoader()) {
            self.imageLoader = imageLoader
        }

        func loadHeroImage() async {
            guard !state.isHeroImageLoading, state.heroImageData == nil else { return }
            state.isHeroImageLoading = true
            defer { state.isHeroImageLoading = false }

            do {
                state.heroImageData = try await imageLoader.load(from: Self.heroImageURL)
            } catch {
                state.heroImageData = nil
            }
        }
    }
}
