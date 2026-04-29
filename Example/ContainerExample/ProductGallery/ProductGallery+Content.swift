import Container
import Foundation

struct ProductGalleryContent {
    let title: String
    let rows: [ImageDetail.Content]
    let isLoading: Bool
}

extension ProductGallery {
    @MainActor
    static func buildContent(from model: Model) -> ProductGalleryContent {
        let rows = model.state.products.map { product in
            ImageDetail.Content(
                id: product.id,
                imageData: model.state.imageDataByProductID[product.id],
                orderNumber: product.orderNumber,
                quantity: product.quantity,
                isImageLoading: model.state.pendingImageProductIDs.contains(product.id)
            )
        }

        return ProductGalleryContent(
            title: "Product Gallery",
            rows: rows,
            isLoading: model.state.isLoading
        )
    }
}
