import Container
import SwiftUI

extension ProductGallery {
    struct Screen: View {
        @Bindable private var model: Model

        init(model: Model) {
            self.model = model
        }

        var body: some View {
            ScreenContainer(
                model: model,
                mapContent: ProductGallery.buildContent(from:),
                display: makeDisplay(content:)
            )
            .refreshable { await model.loadProductGallery() }
            .task { await model.loadProductGallery() }
        }

        private func makeDisplay(content: ProductGalleryContent) -> Display {
            Display(content: content)
        }
    }

    struct Display: View {
        let content: ProductGalleryContent
        @Environment(\.navRouter) private var navRouter

        var body: some View {
            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ]
            ScrollView {
                LazyVGrid(columns: columns, spacing: 32) {
                    ForEach(content.rows) { row in
                        ImageDetail(content: row, arrangement: .stacked)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(content.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("A") { navRouter?.push(ProductsRoute.detailAlpha) }
                    Button("B") { navRouter?.push(ProductsRoute.detailBeta) }
                }
            }
            .overlay {
                if content.isLoading && content.rows.isEmpty {
                    ProgressView()
                        .scaleEffect(1.2)
                }
            }
        }
    }
}
