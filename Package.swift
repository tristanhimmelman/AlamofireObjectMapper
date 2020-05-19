// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlamofireObjectMapper",
    platforms: [
        .iOS(.v11)
    ],
    products: [.library(name: "AlamofireObjectMapper",
                        targets: ["AlamofireObjectMapper"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", "5.0.0"..."5.0.0"),
        .package(url: "https://github.com/freesuraj/ObjectMapper", .branch("spm"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "AlamofireObjectMapper",
            dependencies: ["Alamofire", "ObjectMapper"]),
        .testTarget(
            name: "AlamofireObjectMapperTests",
            dependencies: ["AlamofireObjectMapper"]),
    ]
)
