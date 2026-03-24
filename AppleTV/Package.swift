// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LeoTV_Companion",
    platforms: [
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "LeoTV_Companion",
            targets: ["LeoTV_Companion"]
        ),
    ],
    targets: [
        .target(
            name: "LeoTV_Companion",
            path: "LeoTV_Companion"
        ),
    ]
)
