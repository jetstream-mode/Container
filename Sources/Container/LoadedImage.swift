import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Decodes image bytes into a resizable SwiftUI `Image`. Use with data produced by an ``ImageLoader``.
public struct LoadedImage: View {
    private let data: Data?
    private let contentMode: ContentMode

    public init(data: Data?, contentMode: ContentMode = .fit) {
        self.data = data
        self.contentMode = contentMode
    }

    public var body: some View {
        Group {
            if let data, let image = Self.decode(data) {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder
            }
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(.quaternary)
    }

    #if canImport(UIKit)
    private static func decode(_ data: Data) -> Image? {
        guard let ui = UIImage(data: data) else { return nil }
        return Image(uiImage: ui)
    }
    #elseif canImport(AppKit)
    private static func decode(_ data: Data) -> Image? {
        guard let ns = NSImage(data: data) else { return nil }
        return Image(nsImage: ns)
    }
    #else
    private static func decode(_: Data) -> Image? { nil }
    #endif
}
