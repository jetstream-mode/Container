import SwiftUI

/// Layout-only row for an image plus product fields; values come from ``Content`` produced by the screen’s Content layer.
public struct ImageDetail: View {
    public enum Arrangement {
        /// Image uses one-third width; order and qty in a column beside it (wide rows).
        case inline
        /// Image on top, text below (narrow grids).
        case stacked
    }

    public struct Content: Equatable, Identifiable {
        public let id: String
        public let imageData: Data?
        public let orderNumber: Int
        public let quantity: Int
        public let isImageLoading: Bool

        public init(
            id: String,
            imageData: Data?,
            orderNumber: Int,
            quantity: Int,
            isImageLoading: Bool = false
        ) {
            self.id = id
            self.imageData = imageData
            self.orderNumber = orderNumber
            self.quantity = quantity
            self.isImageLoading = isImageLoading
        }
    }

    private let content: Content
    private let arrangement: Arrangement

    public init(content: Content, arrangement: Arrangement = .inline) {
        self.content = content
        self.arrangement = arrangement
    }

    public var body: some View {
        switch arrangement {
        case .inline:
            inlineBody
        case .stacked:
            stackedBody
        }
    }

    private var inlineBody: some View {
        GeometryReader { geometry in
            let imageWidth = geometry.size.width / 3
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    LoadedImage(data: content.imageData, contentMode: .fill)
                    if content.isImageLoading {
                        ProgressView()
                    }
                }
                .frame(width: imageWidth, height: imageWidth * 0.85)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "Order #\(content.orderNumber)")
                        .font(.subheadline.weight(.semibold))
                    Text(verbatim: "Qty \(content.quantity)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: 120)
    }

    private var stackedBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                LoadedImage(data: content.imageData, contentMode: .fill)
                if content.isImageLoading {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(4 / 3, contentMode: .fit)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(verbatim: "Order #\(content.orderNumber)")
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(verbatim: "Qty \(content.quantity)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
