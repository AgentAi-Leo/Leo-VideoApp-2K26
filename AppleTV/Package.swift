// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ViewerApp",
    platforms: [
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "ViewerApp",
            targets: ["ViewerApp"]
        ),
    ],
    targets: [
        .target(
            name: "ViewerApp",
            path: "ViewerApp"
        ),
    ]
)
