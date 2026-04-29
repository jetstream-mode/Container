import Container
import Foundation
import Observation

enum ProductGallery {}

extension ProductGallery {
    struct Navigation: Equatable {}

    struct State: Equatable {
        var products: [Product] = []
        var imageDataByProductID: [String: Data] = [:]
        /// Product IDs whose image request has not finished yet (success or failure).
        var pendingImageProductIDs: Set<String> = []
        var isLoading = false
    }

    @MainActor
    @Observable
    final class Model {
        var navigation = Navigation()
        var state = State()

        private let productsFetcher: any ProductsFetching
        private let imageLoader: any ImageLoader

        init(
            productsFetcher: any ProductsFetching = MockProductsService(),
            imageLoader: any ImageLoader = URLSessionImageLoader()
        ) {
            self.productsFetcher = productsFetcher
            self.imageLoader = imageLoader
        }

        func loadProductGallery() async {
            guard !state.isLoading else { return }
            state.isLoading = true
            defer { state.isLoading = false }

            do {
                let products = try await productsFetcher.getProducts()
                state.products = products
                state.imageDataByProductID = [:]
                state.pendingImageProductIDs = Set(products.map(\.id))

                let loader = imageLoader
                await withTaskGroup(of: Void.self) { group in
                    for product in products {
                        let id = product.id
                        let url = product.imageUrl
                        group.addTask {
                            let data = try? await loader.load(from: url)
                            await MainActor.run {
                                if let data {
                                    self.state.imageDataByProductID[id] = data
                                }
                                self.state.pendingImageProductIDs.remove(id)
                            }
                        }
                    }
                }
            } catch {
                state.products = []
                state.imageDataByProductID = [:]
                state.pendingImageProductIDs = []
            }
        }
    }
}
