// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "toast-flow",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "ToastFlow",
            targets: ["ToastFlow"]),
    ],
    dependencies: [
        .package(url: "https://github.com/miejoy/window-flow.git", branch: "main"),
        .package(url: "https://github.com/miejoy/auto-config.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "ToastFlow",
            dependencies: [
                .product(name: "WindowFlow", package: "window-flow"),
                .product(name: "AutoConfig", package: "auto-config"),
            ]
        ),
        .testTarget(
            name: "ToastFlowTests",
            dependencies: ["ToastFlow"]),
    ]
)
