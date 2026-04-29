// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Container",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "Container", targets: ["Container"]),
    ],
    targets: [
        .target(name: "Container"),
        .testTarget(
            name: "ContainerTests",
            dependencies: ["Container"]
        ),
    ]
)
