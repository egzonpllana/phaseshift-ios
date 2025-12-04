// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhaseShift",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "PhaseShift",
            targets: ["PhaseShift"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PhaseShift",
            dependencies: [],
            path: "Sources/PhaseShift"
        ),
    ]
)

