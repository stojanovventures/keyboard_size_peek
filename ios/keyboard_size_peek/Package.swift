// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "keyboard_size_peek",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "keyboard-size-peek", targets: ["keyboard_size_peek"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "keyboard_size_peek",
            dependencies: [],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
