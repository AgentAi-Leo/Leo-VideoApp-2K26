// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LeoTVCompanion",
    platforms: [
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "LeoTVCompanion",
            targets: ["LeoTVCompanion"]
        ),
    ],
    targets: [
        .target(
            name: "LeoTVCompanion",
            path: "LeoTVCompanion"
        ),
    ]
)
