// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SymFacePublicSubset",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SymFacePublic",
            targets: ["SymFacePublic"]
        )
    ],
    targets: [
        .target(name: "SymFacePublic"),
        .testTarget(
            name: "SymFacePublicTests",
            dependencies: ["SymFacePublic"]
        )
    ]
)

