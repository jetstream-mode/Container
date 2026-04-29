import Foundation

/// Builds `[Product]` by round-tripping through JSON so tests and previews use the same decode path as a real API.
struct MockProductsService: ProductsFetching {
    /// 100 distinct Picsum images via stable seeds (avoids relying on numeric id availability).
    private static let imageUrlStrings: [String] = (0 ..< 100).map { index in
        "https://picsum.photos/seed/pg\(index)/400/300"
    }

    func getProducts() async throws -> [Product] {
        var products: [Product] = []
        products.reserveCapacity(Self.imageUrlStrings.count)
        for (index, urlString) in Self.imageUrlStrings.enumerated() {
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            products.append(
                Product(
                    id: "product-\(index + 1)",
                    imageUrl: url,
                    orderNumber: Int.random(in: 1_000_000 ... 9_000_000),
                    quantity: Int.random(in: 1 ... 10)
                )
            )
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(products)
        return try JSONDecoder().decode([Product].self, from: data)
    }
}
