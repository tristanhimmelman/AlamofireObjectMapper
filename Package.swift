// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "AlamofireObjectMapper",
    products: [
        .library(
            name: "AlamofireObjectMapper",
            targets: ["AlamofireObjectMapper"]),
    ],
    targets: [
        .target(
            name: "AlamofireObjectMapper",
            dependencies: []),
        .testTarget(
            name: "AlamofireObjectMapperTests",
            dependencies: ["AlamofireObjectMapper"]),
    ]
)
