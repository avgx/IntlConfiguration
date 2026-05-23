// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IntlConfiguration",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .tvOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "IntlConfiguration",
            targets: ["IntlConfiguration"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/avgx/IntlWireFormat", from: "1.0.0"),
        .package(url: "https://github.com/avgx/RequestResponse", from: "2.0.0"),
        .package(url: "https://github.com/avgx/SafeEnum", from: "1.0.0"),
        .package(url: "https://github.com/avgx/URLKit", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "IntlConfiguration",
            dependencies: [
                .product(name: "IntlWireFormat", package: "IntlWireFormat"),
                .product(name: "RequestResponse", package: "RequestResponse"),
                .product(name: "SafeEnum", package: "SafeEnum"),
            ]
        ),
        .testTarget(
            name: "IntlConfigurationTests",
            dependencies: [
                "IntlConfiguration",
                .product(name: "URLKit", package: "URLKit"),
            ],
            resources: [.process("Resources")]
        ),
    ]
)
